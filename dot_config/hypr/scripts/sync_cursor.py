#!/usr/bin/env python3
"""Tint a separate Bibata copy; called by the existing wallpaper accent sync."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile
import zipfile

HOME = Path.home()
SOURCE = HOME / '.local/share/icons/Bibata-Modern-Ice'
PREFIX = 'Bibata-Accent-'
CONFIGS = (
    '.config/gtk-3.0/settings.ini', '.config/gtk-4.0/settings.ini',
    '.config/xsettingsd/xsettingsd.conf',
    '.local/share/icons/default/index.theme', '.icons/default/index.theme',
)


def atomic_write(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = path.stat().st_mode & 0o777 if path.exists() else 0o644
    fd, name = tempfile.mkstemp(prefix='.' + path.name, dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
        os.chmod(name, mode)
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def recolor_xcursor(data, rgb):
    """Keep all headers, hotspots, frame delays and alpha bytes unchanged."""
    import numpy as np
    result = bytearray(data)
    magic, header, version, count = struct.unpack_from('<4I', data)
    if magic != 0x72756358 or header < 16 or header + count * 12 > len(data):
        raise ValueError('Invalid Xcursor header')
    for i in range(count):
        kind, nominal, position = struct.unpack_from('<3I', data, header + i * 12)
        if kind != 0xfffd0002:
            continue
        hlen, chunk_kind, size, ver, width, height, xhot, yhot, delay = struct.unpack_from('<9I', data, position)
        if hlen < 36 or chunk_kind != kind or size != nominal or xhot >= width or yhot >= height:
            raise ValueError('Invalid Xcursor image')
        start, length = position + hlen, width * height
        if start + length * 4 > len(data):
            raise ValueError('Truncated Xcursor image')
        pixels = np.frombuffer(result, dtype='<u4', count=length, offset=start)
        red, green, blue = (pixels >> 16) & 255, (pixels >> 8) & 255, pixels & 255
        grey = (red == green) & (green == blue)
        value = red[grey]
        # Xcursor uses premultiplied RGB; multiplication preserves alpha and edges.
        pixels[grey] = ((pixels[grey] & 0xff000000)
                        | (((value * rgb[0] + 127) // 255) << 16)
                        | (((value * rgb[1] + 127) // 255) << 8)
                        | ((value * rgb[2] + 127) // 255))
    return bytes(result)


def recolor_svg(data, rgb):
    def replace(match):
        value = match.group(1)
        channels = tuple(int(value[i:i+2], 16) for i in (0, 2, 4))
        if len(set(channels)) != 1:
            return match.group(0)  # Preserve colored status symbols and spinner segments.
        return '#' + ''.join(f'{(channels[0] * c + 127) // 255:02x}' for c in rgb)
    return re.sub(r'#([0-9a-fA-F]{6})\b', replace, data.decode()).encode()


def build_theme(source, destination, color):
    source, destination = Path(source), Path(destination)
    if destination.exists():
        if (destination / '.bibata-accent').read_text().strip() != color:
            raise ValueError('Destination exists but is not the expected generated theme')
        return destination
    rgb = tuple(int(color[i:i+2], 16) for i in (0, 2, 4))
    destination.parent.mkdir(parents=True, exist_ok=True)
    stage = Path(tempfile.mkdtemp(prefix='.bibata-build-', dir=destination.parent))
    try:
        (stage / 'cursors').mkdir()
        for cursor in (source / 'cursors').iterdir():
            output = stage / 'cursors' / cursor.name
            if cursor.is_symlink():
                target = Path(os.readlink(cursor)).name
                if not (source / 'cursors' / target).is_file():
                    raise ValueError(f'Missing alias target: {target}')
                output.symlink_to(target)
            else:
                output.write_bytes(recolor_xcursor(cursor.read_bytes(), rgb))
        (stage / 'hyprcursors').mkdir()
        for cursor in (source / 'hyprcursors').glob('*.hlc'):
            with zipfile.ZipFile(cursor) as src, zipfile.ZipFile(stage / 'hyprcursors' / cursor.name, 'w') as dst:
                for item in src.infolist():
                    data = src.read(item.filename)
                    if item.filename.endswith('.svg'):
                        data = recolor_svg(data, rgb)
                    elif item.filename.endswith('.png'):
                        raise ValueError('This Bibata theme is expected to contain SVG cursors')
                    dst.writestr(item, data)
        name = destination.name
        (stage / 'index.theme').write_text(f'[Icon Theme]\nName={name}\nComment=Bibata with wallpaper accent\nInherits=Bibata-Modern-Ice\n')
        (stage / 'cursor.theme').write_text(f'[Icon Theme]\nInherits={name}\n')
        manifest = (source / 'manifest.hl').read_text()
        (stage / 'manifest.hl').write_text(re.sub(r'^name\s*=.*$', 'name = ' + name, manifest, flags=re.M))
        (stage / '.bibata-accent').write_text(color + '\n')
        os.rename(stage, destination)
    finally:
        if stage.exists():
            shutil.rmtree(stage)
    return destination


def config_text(rel, text, name):
    if rel.endswith('environment.lua'):
        return re.sub(r'(hl\.env\("(?:XCURSOR_THEME|HYPRCURSOR_THEME)",\s*")[^"]+("\))',
                      lambda m: m[1] + name + m[2], text)
    if rel.endswith('/uwsm/env'):
        return re.sub(r'^(export (?:XCURSOR_THEME|HYPRCURSOR_THEME)=).*$',
                      lambda m: m[1] + name, text, flags=re.M)
    if rel.endswith('settings.ini'):
        return re.sub(r'^gtk-cursor-theme-name=.*$', 'gtk-cursor-theme-name=' + name, text, flags=re.M)
    if rel.endswith('xsettingsd.conf'):
        return re.sub(r'^Gtk/CursorThemeName\s+.*$', f'Gtk/CursorThemeName "{name}"', text, flags=re.M)
    return re.sub(r'^Inherits=.*$', 'Inherits=' + name, text, flags=re.M)


def command(args, required=False):
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=3)
        if result.returncode and required:
            raise RuntimeError(result.stderr or result.stdout)
        return result
    except (OSError, subprocess.TimeoutExpired):
        if required:
            raise
        return None


def activate(name, size=20, is_current=lambda: True):
    if not is_current():
        return False
    # Check the compositor can load the complete new copy before switching apps.
    result = command(['hyprctl', 'setcursor', name, str(size)], required=True)
    if result.stdout.strip().lower() != 'ok':
        raise RuntimeError('Hyprland did not accept cursor theme: ' + result.stdout)
    if not is_current():
        return False
    state = Path(os.environ.get('XDG_STATE_HOME') or HOME / '.local/state') / 'hypr'
    atomic_write(state / 'cursor-theme', (name + '\n').encode())
    for rel in CONFIGS:
        if not is_current():
            return False
        path = HOME / rel
        if path.is_file():
            old = path.read_text()
            new = config_text(rel, old, name)
            if new != old:
                atomic_write(path, new.encode())
    if not is_current():
        return False
    command(['gsettings', 'set', 'org.gnome.desktop.interface', 'cursor-theme', name], required=True)
    # New Hyprland-launched apps and D-Bus/systemd-launched apps get the same theme.
    if not is_current():
        return False
    command(['hyprctl', 'eval', f'hl.env("XCURSOR_THEME", "{name}"); hl.env("HYPRCURSOR_THEME", "{name}")'], required=True)
    if not is_current():
        return False
    command(['dbus-update-activation-environment', '--systemd', f'XCURSOR_THEME={name}', f'HYPRCURSOR_THEME={name}'], required=True)
    # xsettingsd supports re-reading its config via SIGHUP; no process restart.
    if not is_current():
        return False
    command(['pkill', '-HUP', '-u', str(os.getuid()), '-x', 'xsettingsd'])
    return is_current()


def sync_color(color, force=False, is_current=lambda: True):
    """Run directly inside sync_border, avoiding a second Python/NumPy startup."""
    color = color.lstrip('#').lower()
    if not re.fullmatch('[0-9a-f]{6}', color):
        raise ValueError('accent must have six hexadecimal digits')
    state = Path(os.environ.get('XDG_STATE_HOME') or HOME / '.local/state') / 'hypr'
    state.mkdir(parents=True, exist_ok=True)
    with (state / 'cursor-accent.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        destination = SOURCE.parent / (PREFIX + color)
        instance = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
        applied_path = state / 'cursor-applied.json'
        try:
            applied = json.loads(applied_path.read_text())
            same_theme = (state / 'cursor-theme').read_text().strip() == destination.name
            valid_theme = (destination / '.bibata-accent').read_text().strip() == color
        except (OSError, ValueError):
            applied, same_theme, valid_theme = {}, False, False
        # A new compositor instance must always activate, even with the same color.
        if (not force and instance and same_theme and valid_theme
                and applied == {'instance': instance, 'theme': destination.name}):
            return False
        if not is_current():
            return False
        build_theme(SOURCE, destination, color)
        if not is_current():
            return False
        if not activate(destination.name, is_current=is_current):
            return False
        atomic_write(applied_path, json.dumps({'instance': instance, 'theme': destination.name}).encode())
        # Keep at most three generated color variants; never delete an original theme.
        generated = sorted((p for p in SOURCE.parent.glob(PREFIX + '*')
                            if re.fullmatch(PREFIX + '[0-9a-f]{6}', p.name)
                            and not p.is_symlink() and (p / '.bibata-accent').is_file()),
                           key=lambda p: p.stat().st_mtime, reverse=True)
        other = [p for p in generated if p != destination]
        for old in other[2:]:
            shutil.rmtree(old)
        return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('color', help='six hexadecimal accent digits')
    parser.add_argument('--output', type=Path, help='build here without changing any settings')
    parser.add_argument('--force', action='store_true', help='reload even if this color is already active')
    args = parser.parse_args()
    color = args.color.lstrip('#').lower()
    if not re.fullmatch('[0-9a-f]{6}', color):
        parser.error('accent must have six hexadecimal digits')
    if args.output:
        build_theme(SOURCE, args.output / (PREFIX + color), color)
        return
    sync_color(color, force=args.force)


if __name__ == '__main__':
    main()
