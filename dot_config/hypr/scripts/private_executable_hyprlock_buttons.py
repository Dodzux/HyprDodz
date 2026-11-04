#!/usr/bin/python3
"""Hover feedback for three Hyprlock image buttons; never reads keyboard input."""
import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import signal
import socket
import subprocess
import sys
import time

NAMES = ('suspend', 'restart', 'shutdown')
OFFSETS = (-128, 0, 128)
TILE = 80
BOTTOM = 16
PASSWORD_MAP = 'hyprlock-input'
BUTTONS_MAP = 'hyprlock-power'
POWER_ACTIONS = ('suspend', 'reboot', 'poweroff')


def navigation(focus, command):
    """Only symbolic UI commands enter here; password characters never do."""
    if command in ('tab-next', 'tab-prev'):
        targets = (None, 0, 1, 2)
        step = 1 if command == 'tab-next' else -1
        return targets[(targets.index(focus) + step) % len(targets)], None
    if command in ('next', 'prev'):
        step = 1 if command == 'next' else -1
        return ((0 if step == 1 else 2) if focus is None else (focus + step) % 3), None
    if command == 'clear':
        return None, None
    if command == 'activate' and focus is not None:
        return None, ['systemctl', POWER_ACTIONS[focus]]
    return focus, None


def render_assets(directory, accent):
    from PIL import Image, ImageDraw, ImageFont
    directory.mkdir(parents=True, exist_ok=True)
    scale = 4
    font = ImageFont.truetype('/usr/share/fonts/TTF/CaskaydiaCoveNerdFont-Regular.ttf', 48 * scale)
    # Use established icon glyphs rather than approximating their outlines.
    # The reference has an outlined crescent, triangular restart arrow, and power.
    glyphs = ('\uf186', '\U000f0709', '\U000f0425')
    heights = (34, 32, 32)
    for index, name in enumerate(NAMES):
        bounds = font.getbbox(glyphs[index])
        glyph = Image.new('L', (bounds[2] - bounds[0], bounds[3] - bounds[1]))
        ImageDraw.Draw(glyph).text((-bounds[0], -bounds[1]), glyphs[index], font=font, fill=255)
        height = heights[index] * scale
        width = round(glyph.width * height / glyph.height)
        glyph = glyph.resize((width, height), Image.Resampling.LANCZOS)
        mask = Image.new('L', (TILE * scale, TILE * scale))
        mask.paste(glyph, ((mask.width - width) // 2, (mask.height - height) // 2))
        mask = mask.resize((TILE, TILE), Image.Resampling.LANCZOS)
        for hover in (False, True):
            # Hover only reduces opacity by 22%; no blur, glow, tile, or caption.
            alpha = mask.point(lambda value: round(value * 0.78)) if hover else mask
            image = Image.new('RGBA', mask.size, (243, 242, 238, 0))
            image.putalpha(alpha)
            image.save(directory / f'{name}-{"hover" if hover else "idle"}.png')


def hovered_button(monitors, cursor):
    """Convert compositor logical pointer coordinates to Hyprlock pixel bounds."""
    for monitor in monitors:
        if monitor.get('disabled') or not monitor.get('dpmsStatus', True):
            continue
        width, height = monitor['width'], monitor['height']
        if monitor.get('transform', 0) % 2:
            width, height = height, width
        scale = monitor.get('scale', 1)
        px = (cursor['x'] - monitor['x']) * scale
        py = (cursor['y'] - monitor['y']) * scale
        if height - BOTTOM - TILE <= py < height - BOTTOM:
            for index, offset in enumerate(OFFSETS):
                if width / 2 + offset - TILE / 2 <= px < width / 2 + offset + TILE / 2:
                    return index
    return None


def ipc_text(path, request):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.settimeout(0.25)
        connection.connect(str(path))
        connection.sendall(request.encode())
        chunks = []
        while True:
            data = connection.recv(65536)
            if not data:
                break
            chunks.append(data)
        return b''.join(chunks).decode()


def ipc(path, request):
    return json.loads(ipc_text(path, request))


def set_focus_map(ipc_path, focus):
    name = PASSWORD_MAP if focus is None else BUTTONS_MAP
    reply = ipc_text(ipc_path, f'dispatch hl.dsp.submap("{name}")').strip()
    if reply != 'ok':
        raise RuntimeError('Lock navigation submap unavailable')


def reset_focus_map(ipc_path):
    try:
        if ipc_text(ipc_path, 'submap').strip() in (PASSWORD_MAP, BUTTONS_MAP):
            ipc_text(ipc_path, 'dispatch hl.dsp.submap("reset")')
    except (OSError, ValueError):
        pass


def publish(directory, assets, previous, selected):
    for index, name in enumerate(NAMES):
        if previous == index or selected == index or previous == -1:
            source = assets / f'{name}-{"hover" if selected == index else "idle"}.png'
            temporary = directory / f'.{name}.png'
            shutil.copyfile(source, temporary)
            os.replace(temporary, directory / f'{name}.png')


def can_refresh(pid):
    try:
        status = Path(f'/proc/{pid}/status').read_text()
        caught = int(re.search(r'^SigCgt:\s*(\w+)', status, re.M)[1], 16)
        return bool(caught & (1 << (signal.SIGUSR2 - 1)))
    except (OSError, TypeError):
        return False


def watch(child, ipc_path, directory, assets, run_action=subprocess.Popen):
    selected = None
    focus = None
    last_cursor = None
    keyboard_active = False
    monitors = []
    next_monitors = 0.0
    errors_reported = False
    started = time.monotonic()
    refresh_again = None
    # The compositor appends fixed action names to this private tmpfs queue.
    # No key text, password buffer, or keyboard device is read by this helper.
    queue = (directory / 'commands').open('r')
    while child.poll() is None:
        try:
            now = time.monotonic()
            if now >= next_monitors:
                monitors = ipc(ipc_path, 'j/monitors')
                next_monitors = now + 2
            cursor = ipc(ipc_path, 'j/cursorpos')
            hovered = hovered_button(monitors, cursor)
            point = (cursor['x'], cursor['y'])
            signals_ready = can_refresh(child.pid)
            ready = now - started >= 0.5 and signals_ready
            if signals_ready and not keyboard_active:
                set_focus_map(ipc_path, None)
                keyboard_active = True
            if keyboard_active:
                if last_cursor is not None and point != last_cursor and focus is not None:
                    focus = None
                    set_focus_map(ipc_path, None)
                # Preserve ordering even for a quick Tab then Enter.
                for _ in range(128):
                    message = queue.readline(64)
                    if not message:
                        break
                    focus, action = navigation(focus, message.strip())
                    set_focus_map(ipc_path, focus)
                    if action is not None and child.poll() is None:
                        run_action(action)
            last_cursor = point
            highlighted = focus if focus is not None else hovered
            if highlighted != selected and ready:
                publish(directory, assets, selected, highlighted)
                try:
                    os.kill(child.pid, signal.SIGUSR2)
                except ProcessLookupError:
                    break
                selected = highlighted
                # A busy renderer may still be loading the previous texture.
                # Retry once so rapid enter/leave cannot leave a stale highlight.
                refresh_again = now + 0.16
            elif refresh_again is not None and now >= refresh_again and can_refresh(child.pid):
                try:
                    os.kill(child.pid, signal.SIGUSR2)
                except ProcessLookupError:
                    break
                refresh_again = None
            time.sleep(0.08)
        except (OSError, ValueError, KeyError, TypeError) as error:
            if not errors_reported:
                print(f'hyprlock-buttons: hover temporarily unavailable ({type(error).__name__}); lock remains active.', file=sys.stderr, flush=True)
                errors_reported = True
            time.sleep(0.5)


def main():
    if len(sys.argv) == 3 and sys.argv[1] == 'render':
        render_assets(Path(sys.argv[2]), (191, 97, 107))
        return
    if sys.argv[1:] != ['lock']:
        raise SystemExit('Usage: hyprlock_buttons.py lock | render DIRECTORY')
    # Every failure in optional decoration falls back to the original locker.
    original_command = ['hyprlock', '--grace', '0', '--immediate-render']
    child = None
    try:
        runtime = Path(os.environ['XDG_RUNTIME_DIR'])
        directory = runtime / 'hyprlock-buttons'
        directory.mkdir(mode=0o700, exist_ok=True)
        guard = (directory / 'lock').open('w')
        try:
            fcntl.flock(guard, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        assets = directory / 'assets'
        config = Path.home() / '.config/hypr/hyprlock.conf'
        match = re.search(r'^\$accent\s*=\s*rgb\(([0-9a-fA-F]{6})\)', config.read_text(), re.M)
        accent_hex = match[1] if match else 'bf616b'
        accent = tuple(int(accent_hex[n:n + 2], 16) for n in (0, 2, 4))
        render_assets(assets, accent)
        publish(directory, assets, -1, None)
        (directory / 'commands').write_text('')
        ipc_path = runtime / 'hypr' / os.environ['HYPRLAND_INSTANCE_SIGNATURE'] / '.socket.sock'
        child = subprocess.Popen(original_command)
        try:
            watch(child, ipc_path, directory, assets)
        except Exception as error:
            print(f'hyprlock-buttons: decoration stopped ({type(error).__name__}); waiting for locker.', file=sys.stderr, flush=True)
        finally:
            reset_focus_map(ipc_path)
        raise SystemExit(child.wait())
    except Exception as error:
        print(f'hyprlock-buttons: optional decoration failed ({type(error).__name__}); starting Hyprlock.', file=sys.stderr, flush=True)
        if child is not None:
            raise SystemExit(child.wait())
        os.execvp(original_command[0], original_command)


if __name__ == '__main__':
    main()
