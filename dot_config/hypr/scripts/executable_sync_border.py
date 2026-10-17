#!/usr/bin/env python3
"""
Sync the Hyprland active border (and hyprlock, hyprtoolkit, quickshell, GTK,
Qt/Kvantum, yazi, neovim, starship, kitty cursor and OpenRGB accents) to the most harmonious
color in the current wallpaper. Greyscale or near-black wallpapers fall back
to Platinum.

Usage: sync_border.py [IMAGE] [--dry-run]
       IMAGE defaults to the wallpaper awww is currently displaying.
"""

import argparse
import colorsys
import fcntl
import glob
import os
import re
import signal
import subprocess
import sys
import time
import json
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed

# numpy and PIL are imported inside extract_color(), not here: they take ~70ms
# to load, and the latest-wins token must be claimed before that — otherwise
# two runs started close together could claim in the wrong order.

PLATINUM = "e5e5e5"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ACCENT_STATE = os.path.join(
    os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state"), "hypr", "accent")
# Latest-wins. Two wallpaper changes in quick succession start two runs; without
# this, whichever finished last won — not necessarily the newest. Each run
# claims TOKEN_FILE on start; the check-and-apply is serialised on LOCK_FILE so
# an older run can't pass the check and then finish applying after a newer one.
RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
TOKEN_FILE = os.path.join(RUNTIME_DIR, "sync_border.token")
LOCK_FILE = os.path.join(RUNTIME_DIR, "sync_border.lock")


def current_wallpaper():
    """Path of the image awww is currently displaying, or None."""
    try:
        out = subprocess.run(["awww", "query"], capture_output=True, text=True, timeout=1.5).stdout
    except (OSError, subprocess.TimeoutExpired):
        return None
    for line in out.splitlines():
        if "currently displaying: image:" in line:
            path = line.split("currently displaying: image:", 1)[1].strip()
            if os.path.isfile(path):
                return path
    return None


def extract_color(image_path):
    """Return (hex, reason) for the most harmonious border color in the image."""
    import numpy as np
    from PIL import Image

    im = Image.open(image_path)
    if getattr(im, "is_animated", False):
        im.seek(0)  # first frame of animated GIF/WebP
    im = im.convert("RGB").resize((150, 150), Image.Resampling.BILINEAR)
    pixels = (np.array(im, dtype=np.float32) / 255.0).reshape(-1, 3)
    r, g, b = pixels[:, 0], pixels[:, 1], pixels[:, 2]

    # 1. Greyscale / near-black detection -> Platinum
    channel_deltas = np.max(pixels, axis=1) - np.min(pixels, axis=1)
    mean_delta = float(np.mean(channel_deltas))
    chromatic_ratio = float(np.mean(channel_deltas > 0.08))
    mean_luminance = float(np.mean(0.299 * r + 0.587 * g + 0.114 * b))
    if chromatic_ratio < 0.035 or mean_delta < 0.035 or (mean_luminance < 0.02 and chromatic_ratio < 0.10):
        return PLATINUM, "monochrome wallpaper"

    # 2. Hue of every pixel. Chroma (max - min channel) is how colourful a pixel
    #    is, independent of how bright it is.
    cmax = np.max(pixels, axis=1)
    chroma = channel_deltas
    hue = np.zeros_like(cmax)
    nonzero = chroma > 0.001
    mask_r = (cmax == r) & nonzero
    hue[mask_r] = ((g[mask_r] - b[mask_r]) / chroma[mask_r]) % 6.0
    mask_g = (cmax == g) & nonzero
    hue[mask_g] = ((b[mask_g] - r[mask_g]) / chroma[mask_g]) + 2.0
    mask_b = (cmax == b) & nonzero
    hue[mask_b] = ((r[mask_b] - g[mask_b]) / chroma[mask_b]) + 4.0
    hue = (hue / 6.0) % 1.0

    valid = (chroma > 0.15) & (cmax > 0.15)
    if np.sum(valid) < 40:
        return PLATINUM, "not enough colored pixels"

    # 3. Chroma^2-weighted hue histogram. The old scorer ranked hue bins mostly
    #    by pixel *count*, so a large, dull, bluish-grey backdrop beat the
    #    wallpaper's actual accent, and step 4's saturation floor then turned
    #    that grey into a steel blue that appears nowhere in the image (e.g.
    #    relaxed_mario.png -> #5b83b9 instead of its lavender; the green CRT in
    #    moments_before_desk.png lost the same way). Weighting by chroma^2 lets
    #    a vivid accent outweigh a big muted area. Neighbouring bins are
    #    smoothed together so one hue split across a bin edge isn't penalised.
    weights = chroma[valid] ** 2
    bins = 36
    hue_indices = (hue[valid] * bins).astype(int) % bins
    hist = np.bincount(hue_indices, weights=weights, minlength=bins)
    smoothed = hist + 0.5 * np.roll(hist, 1) + 0.5 * np.roll(hist, -1)
    best_bin = int(np.argmax(smoothed))
    in_peak = np.isin(hue_indices, [(best_bin - 1) % bins, best_bin, (best_bin + 1) % bins])
    best_rgb = (pixels[valid][in_peak] * weights[in_peak, None]).sum(axis=0) / weights[in_peak].sum()

    # 4. Clamp lightness/saturation so the border glows on dark themes
    h, l, s = colorsys.rgb_to_hls(*best_rgb)
    l, s = float(np.clip(l, 0.54, 0.72)), float(np.clip(s, 0.40, 0.90))
    rgb = (int(np.round(np.clip(c * 255, 0, 255))) for c in colorsys.hls_to_rgb(h, l, s))
    return "".join(f"{c:02x}" for c in rgb), f"hue bin {best_bin}"


def companion(hex_color):
    """A second colour that sits beside the accent: its hue turned 60 degrees,
    as the old sapphire/mauve prompt was. A grey accent has no hue to turn, so
    it gets a darker grey instead."""
    rgb = [int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    h, l, s = colorsys.rgb_to_hls(*rgb)
    if max(rgb) - min(rgb) < 0.08:  # same chroma cutoff as extract_color()
        l -= 0.25
    else:
        h = (h + 60 / 360) % 1.0
    return "".join(f"{round(c * 255):02x}" for c in colorsys.hls_to_rgb(h, l, s))


def on_accent(hex_color):
    """Text colour for the accent: near-black on a bright accent, white otherwise.
    Same brightness test and threshold as the Graphite theme's on(), so GTK,
    Qt and the theme's own fallbacks agree."""
    r, g, b = (int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    return "111111" if (r * 299 + g * 587 + b * 114) / 1000 >= 156 else "ffffff"


def codex_palette(hex_color):
    """Readable code colors related to the wallpaper hue, on a dark surface."""
    rgb = [int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    hue, _, saturation = colorsys.rgb_to_hls(*rgb)
    if max(rgb) - min(rgb) < 0.08:
        saturation = 0.0
    saturation = min(saturation, 0.65)
    roles = ((16, 0, 0.68, 1.0), (17, 0, 0.82, 0.45),
             (18, -28, 0.73, 0.8), (19, 24, 0.76, 0.8),
             (20, 52, 0.75, 0.75), (21, -52, 0.75, 0.65))
    return {str(slot): "".join(f"{round(channel * 255):02x}" for channel in
                colorsys.hls_to_rgb((hue + offset / 360) % 1, lightness, saturation * factor))
            for slot, offset, lightness, factor in roles}


def shift_lightness(hex_color, dl):
    """The accent with its HLS lightness moved by dl (clamped to 0..1)."""
    rgb = [int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    h, l, s = colorsys.rgb_to_hls(*rgb)
    return "".join(f"{round(c * 255):02x}" for c in colorsys.hls_to_rgb(h, min(1.0, max(0.0, l + dl)), s))


def btop_theme(hex_color):
    """Nord neutrals with wallpaper-derived UI/graph colors and clear heat alerts."""
    selected = shift_lightness(hex_color, -0.18)
    border = shift_lightness(hex_color, -0.12)
    colors = {
        'main_bg': '2e3440', 'main_fg': 'd8dee9',
        'title': shift_lightness(hex_color, 0.08), 'hi_fg': hex_color,
        'selected_bg': selected, 'selected_fg': on_accent(selected),
        'inactive_fg': '7b8498', 'graph_text': 'd8dee9',
        'meter_bg': '434c5e', 'proc_misc': hex_color,
        'followed_bg': selected, 'followed_fg': on_accent(selected),
        'proc_banner_bg': selected, 'proc_banner_fg': on_accent(selected),
        'proc_follow_bg': selected, 'proc_pause_bg': '80662e',
        'cpu_box': border, 'mem_box': border, 'net_box': border, 'proc_box': border,
        'div_line': shift_lightness(hex_color, -0.28),
        'temp_start': 'a3be8c', 'temp_mid': 'ebcb8b', 'temp_end': 'bf616a',
    }
    for graph in ('cpu', 'free', 'cached', 'available', 'used', 'download', 'upload', 'process'):
        for stop, delta in (('start', -0.18), ('mid', 0), ('end', 0.15)):
            colors[f'{graph}_{stop}'] = shift_lightness(hex_color, delta)
    return '# Wallpaper accent; generated by sync_border.py.\n' + ''.join(
        f'theme[{key}]="#{value}"\n' for key, value in colors.items())


def write_btop_theme(config_dir, hex_color):
    config = os.path.join(config_dir, 'btop.conf')
    if not os.path.isfile(config):
        return
    themes = os.path.join(config_dir, 'themes')
    os.makedirs(themes, exist_ok=True)
    write_atomic(os.path.join(themes, 'wallpaper.theme'), btop_theme(hex_color))
    rewrite(config, [(r'^color_theme[ \t]*=.*$', 'color_theme = "wallpaper"')])


def write_atomic(path, content):
    path = os.fspath(path)
    mode = os.stat(path).st_mode & 0o777 if os.path.exists(path) else 0o600
    fd, temporary = tempfile.mkstemp(prefix='.' + os.path.basename(path), dir=os.path.dirname(path))
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(content)
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def rewrite(path, substitutions):
    """Apply (regex, replacement) pairs to a file in place, atomically."""
    path = os.path.expanduser(path)
    if not os.path.isfile(path):
        return
    with open(path) as f:
        content = f.read()
    new = content
    for pattern, repl in substitutions:
        new = re.sub(pattern, repl, new, flags=re.MULTILINE)
    if new != content:
        write_atomic(path, new)


def rewrite_ini(path, values):
    """Set existing `key=value` lines per [section] ({section: {key: value}}).
    Keys repeat across sections in Kvantum's kvconfig, so a plain regex can't."""
    path = os.path.expanduser(path)
    if not os.path.isfile(path):
        return
    with open(path) as f:
        content = f.read()
    lines = content.split("\n")
    section = None
    for i, line in enumerate(lines):
        if line.startswith("[") and line.rstrip().endswith("]"):
            section = line.strip()[1:-1]
        elif "=" in line and section in values:
            key = line.split("=", 1)[0].strip()
            if key in values[section]:
                lines[i] = f"{key}={values[section][key]}"
    new = "\n".join(lines)
    if new != content:
        write_atomic(path, new)


def render(template, path, tokens):
    """Write TEMPLATE to PATH with each @TOKEN@ replaced, if it changed."""
    template, path = os.path.expanduser(template), os.path.expanduser(path)
    if not os.path.isfile(template):
        return
    with open(template) as f:
        new = f.read()
    for token, value in tokens.items():
        new = new.replace(f"@{token}@", value)
    try:
        with open(path) as f:
            if f.read() == new:
                return
    except OSError:
        pass
    write_atomic(path, new)


def update_qt_palette(hex_color, config_dir=None):
    """Keep all current Qt palette roles in sync for applications loading the theme."""
    config_dir = config_dir or os.path.expanduser("~/.config/qt6ct")
    scheme = os.path.join(config_dir, "colors", "quickshell.conf")
    if not os.path.isfile(scheme):
        return
    with open(scheme) as stream:
        content = stream.read()
    foreground = on_accent(hex_color)
    def colors(match):
        values = [value.strip() for value in match[2].split(",")]
        if len(values) < 21:
            return match[0]
        enabled = match[1] != "disabled_colors"
        if enabled:
            values[12], values[13] = "#ff" + hex_color, "#ff" + foreground
        if len(values) == 21:
            values.append(values[12])  # Qt 6.6+ Accent role.
        if enabled:
            values[21] = "#ff" + hex_color
        return match[1] + "=" + ", ".join(values)
    updated = re.sub(r"^(active_colors|inactive_colors|disabled_colors)=(.*)$", colors, content, flags=re.M)
    if updated == content:
        return
    write_atomic(scheme, updated)


def apply_files(hex_color, token):
    """Keep unrelated targets working if an optional configuration cannot be written."""
    errors = []
    fg = on_accent(hex_color)

    def guarded(method, *args):
        check_latest(token)
        try:
            globals()[method](*args)
        except OSError as error:
            message = f'{args[0]}: {error}'
            errors.append(message)
            log_message(f'{token} settings: {message}')

    def rewrite(*args): guarded('rewrite', *args)
    def rewrite_ini(*args): guarded('rewrite_ini', *args)
    def render(*args): guarded('render', *args)

    rewrite("~/.config/hypr/hyprlock.conf", [
        (r"^\$accent\s*=.*$", f"$accent   = rgb({hex_color})"),
        (r"^\$accentAlpha\s*=.*$", f"$accentAlpha = {hex_color}"),
    ])
    rewrite("~/.config/hypr/hyprtoolkit.conf", [
        (r"^accent\s*=.*$", f"accent = 0xFF{hex_color}"),
    ])
    for css in ("~/.config/gtk-3.0/gtk.css", "~/.config/gtk-4.0/gtk.css", "~/.config/gtk-4.0/gtk-dark.css"):
        rewrite(css, [
            (r"@define-color\s+accent_color\s+#[0-9a-fA-F]+;", f"@define-color accent_color #{hex_color};"),
            (r"@define-color\s+accent_bg_color\s+#[0-9a-fA-F]+;", f"@define-color accent_bg_color #{hex_color};"),
            (r"@define-color\s+accent_fg_color\s+#[0-9a-fA-F]+;", f"@define-color accent_fg_color #{fg};"),
        ])
    render("~/.config/Kvantum/Graphite/GraphiteDark.svg.in", "~/.config/Kvantum/Graphite/GraphiteDark.svg", {
        "ACCENT": f"#{hex_color}",
        "ACCENT_LIGHT": f"#{shift_lightness(hex_color, 0.07)}",
        "ACCENT_DARK": f"#{shift_lightness(hex_color, -0.08)}",
    })
    rewrite_ini("~/.config/Kvantum/Graphite/GraphiteDark.kvconfig", {
        "GeneralColors": {"highlight.color": f"#{hex_color}", "inactive.highlight.color": f"#{hex_color}",
                          "highlight.text.color": f"#{fg}"},
        "PanelButtonCommand": {"text.toggle.color": f"#{fg}"},
        "PanelButtonTool": {"text.toggle.color": f"#{fg}"},
        "ItemView": {"text.press.color": f"#{fg}"},
        "MenuItem": {"text.focus.color": f"#{fg}"},
    })
    rewrite("~/.config/qt6ct/qss/hyprblur-round.qss", [
        (r"#[0-9a-fA-F]{6};([ \t]*/\* accent \*/)", rf"#{hex_color};\g<1>"),
    ])
    guarded('update_qt_palette', hex_color)
    rewrite("~/.config/starship.toml", [
        (r'^accent[ \t]*=[ \t]*"#[0-9a-fA-F]{6}"[ \t]*$', f'accent = "#{hex_color}"'),
        (r'^accent2[ \t]*=[ \t]*"#[0-9a-fA-F]{6}"[ \t]*$', f'accent2 = "#{companion(hex_color)}"'),
    ])
    rewrite("~/.config/kitty/kitty.conf", [
        # Custom Codex syntax and UI accents update live in Kitty.
        (r"^color4[ \t]+#[0-9a-fA-F]{6}[ \t]*$", f"color4  #{hex_color}"),
        (r"^color12[ \t]+#[0-9a-fA-F]{6}[ \t]*$", f"color12 #{hex_color}"),
        *[(rf"^color{slot}[ \t]+#[0-9a-fA-F]{{6}}[ \t]*$", f"color{slot} #{color}")
          for slot, color in codex_palette(hex_color).items()],
        (r"^cursor[ \t]+#[0-9a-fA-F]{6}[ \t]*$", f"cursor                  #{hex_color}"),
        (r"^selection_background[ \t]+#[0-9a-fA-F]{6}[ \t]*$", f"selection_background    #{hex_color}"),
        (r"^selection_foreground[ \t]+#[0-9a-fA-F]{6}[ \t]*$", f"selection_foreground    #{fg}"),
    ])
    rewrite("~/.config/yazi/theme.toml", [
        (rf'^(.*\b{key} = ")#[0-9a-fA-F]{{6}}(".*#\s*accent: {key}\s*)$', rf"\g<1>#{hex_color}\g<2>")
        for key in ("fg", "bg")
    ])
    guarded('write_btop_theme', os.path.join(
        os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config"), "btop"), hex_color)
    # A native OpenCode theme, not terminal palette overrides. Keep its syntax
    # and feedback colours fixed; only UI accents follow the wallpaper.
    opencode_config = os.path.join(
        os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config"), "opencode")
    try:
        check_latest(token)
        os.makedirs(os.path.join(opencode_config, "themes"), exist_ok=True)
        render(os.path.join(SCRIPT_DIR, "opencode-wallpaper.json.in"),
               os.path.join(opencode_config, "themes", "opencode-wallpaper.json"), {
                   "ON_ACCENT": f"#{fg}",
                   **{f"ACCENT_{step}": f"#{shift_lightness(hex_color, delta)}"
                      for step, delta in ((100, 0.10), (200, 0), (300, -0.08),
                                          (400, -0.16), (500, -0.24), (600, -0.32),
                                          (700, -0.40), (800, -0.48), (900, -0.56))},
               })
    except OSError as error:
        errors.append(f'OpenCode theme: {error}')
        log_message(f'{token} settings: OpenCode theme: {error}')
    return errors

class Superseded(Exception):
    pass


def extract_color_cached(image):
    """Share analysis between wallpaper loading and subsequent reload events."""
    import hashlib
    metadata = os.stat(image)
    identity = f'{os.path.realpath(image)}:{metadata.st_mtime_ns}:{metadata.st_size}:chroma2-v1'
    name = hashlib.sha256(identity.encode()).hexdigest()
    cache_dir = os.path.join(os.path.dirname(ACCENT_STATE), 'wallpaper-colors')
    os.makedirs(cache_dir, exist_ok=True)
    path = os.path.join(cache_dir, name + '.json')
    with open(os.path.join(RUNTIME_DIR, 'accent-color-' + name + '.lock'), 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            with open(path) as stream:
                saved = json.load(stream)
            if re.fullmatch('[0-9a-f]{6}', saved['color']) and isinstance(saved['reason'], str):
                return saved['color'], saved['reason']
        except (OSError, ValueError, KeyError, TypeError):
            pass
        color, reason = extract_color(image)
        write_atomic(path, json.dumps({'color': color, 'reason': reason}))
        return color, reason


def claim_token():
    """Publish a complete request before extraction or external work starts."""
    with open(LOCK_FILE + '.request', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        token = f"{os.getpid()}-{time.monotonic_ns()}"
        write_atomic(TOKEN_FILE, token)
        return token


def is_latest(token):
    if token is None:
        return True
    try:
        with open(TOKEN_FILE) as stream:
            return stream.read() == token
    except OSError:
        return False


def check_latest(token):
    if not is_latest(token):
        raise Superseded()


def log_message(message):
    path = os.path.join(os.path.dirname(ACCENT_STATE), 'accent-sync.log')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(LOCK_FILE + '.log', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if os.path.exists(path) and os.path.getsize(path) > 512 * 1024:
            os.replace(path, path + '.1')
        with open(path, 'a') as stream:
            stream.write(time.strftime('%Y-%m-%d %H:%M:%S ') + message.rstrip() + '\n')


def checked_command(args, timeout=2):
    result = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
    if result.returncode:
        raise RuntimeError((result.stderr or result.stdout or f'exit {result.returncode}').strip())
    return result


def reload_kitty(hex_color, token):
    result = subprocess.run(
        ['pgrep', '-u', str(os.getuid()), '-x', 'kitty'], capture_output=True, text=True, timeout=1)
    if result.returncode not in (0, 1):
        raise RuntimeError(result.stderr.strip())
    for pid in result.stdout.split():
        check_latest(token)
        try:
            os.kill(int(pid), signal.SIGUSR1)
        except ProcessLookupError:
            pass


def reload_opencode(hex_color, token):
    # OpenCode v2's SIGUSR2 handler re-discovers custom theme files. Only signal
    # interactive clients that have installed it, never the background service.
    result = subprocess.run(
        ['pgrep', '-u', str(os.getuid()), '-x', 'opencode'], capture_output=True, text=True, timeout=1)
    if result.returncode not in (0, 1):
        raise RuntimeError(result.stderr.strip())
    for pid in result.stdout.split():
        check_latest(token)
        try:
            if not all(os.readlink(f'/proc/{pid}/fd/{fd}').startswith('/dev/pts/') for fd in (0, 1)):
                continue
            with open(f'/proc/{pid}/cmdline', 'rb') as stream:
                args = stream.read().split(b'\0')[1:]
            if any(arg in (b'serve', b'service', b'run', b'api') for arg in args):
                continue
            with open(f'/proc/{pid}/status') as stream:
                caught = re.search(r'^SigCgt:\s*([0-9a-fA-F]+)$', stream.read(), re.MULTILINE)
            if not caught or not int(caught[1], 16) & (1 << (signal.SIGUSR2 - 1)):
                continue
            check_latest(token)
            os.kill(int(pid), signal.SIGUSR2)
        except (FileNotFoundError, ProcessLookupError):
            pass


def reload_btop(hex_color, token):
    # Native config/theme reload; never signal a client before its handler exists.
    result = subprocess.run(
        ['pgrep', '-u', str(os.getuid()), '-x', 'btop'], capture_output=True, text=True, timeout=1)
    if result.returncode not in (0, 1):
        raise RuntimeError(result.stderr.strip())
    for pid in result.stdout.split():
        check_latest(token)
        try:
            with open(f'/proc/{pid}/cmdline', 'rb') as stream:
                args = stream.read().split(b'\0')[1:]
            if any(arg in (b'-c', b'--config') or arg.startswith(b'--config=') for arg in args):
                continue  # A custom config is independent of this desktop theme.
            with open(f'/proc/{pid}/status') as stream:
                caught = re.search(r'^SigCgt:\s*([0-9a-fA-F]+)$', stream.read(), re.MULTILINE)
            if not caught or not int(caught[1], 16) & (1 << (signal.SIGUSR2 - 1)):
                continue
            check_latest(token)
            os.kill(int(pid), signal.SIGUSR2)
        except (FileNotFoundError, ProcessLookupError):
            pass


def update_border(hex_color, token):
    border = f'{{ "rgba({hex_color}ee)", "rgba({hex_color}00)" }}'
    lua = f"hl.config({{ general = {{ col = {{ active_border = {{ colors = {border}, angle = 45 }} }} }} }})"
    checked_command(['hyprctl', 'eval', lua], timeout=1)


def update_quickshell(hex_color, token):
    checked_command(['qs', 'ipc', 'call', 'theme', 'setAccent', hex_color], timeout=1)


def update_cursor(hex_color, token):
    from sync_cursor import sync_color
    sync_color(hex_color, force=True, is_current=lambda: is_latest(token))


def update_rgb(hex_color, token):
    checked_command([os.path.join(SCRIPT_DIR, 'openrgb_color.sh'), hex_color, token or ''], timeout=14)


def update_neovim(hex_color, token):
    errors = []
    for sock in sorted(glob.glob(os.path.join(RUNTIME_DIR, 'nvim.*.0'))):
        check_latest(token)
        try:
            checked_command(['nvim', '--server', sock, '--remote-expr', "v:lua.require'accent'.reload()"], timeout=2)
        except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
            errors.append(f'{sock}: {error}')
    if errors:
        raise RuntimeError('; '.join(errors))


def run_target(name, action, hex_color, token):
    started = time.monotonic()
    try:
        # Device scripts already have separate keyboard/mouse locks. An outer
        # RGB lock would make the keyboard wait for a sleeping wireless mouse.
        if name == 'rgb':
            check_latest(token)
            action(hex_color, token)
        else:
            with open(LOCK_FILE + '.' + name, 'a') as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                check_latest(token)
                for attempt in range(2):
                    try:
                        action(hex_color, token)
                        break
                    except (OSError, RuntimeError, subprocess.TimeoutExpired):
                        if attempt:
                            raise
                        check_latest(token)
                        time.sleep(0.08)
        status = 'ok' if is_latest(token) else 'superseded'
        error = None
    except Superseded:
        status, error = 'superseded', None
    except Exception as exc:
        status, error = 'error', str(exc)
        log_message(f'{token} {name}: {error}')
    return {'status': status, 'milliseconds': round((time.monotonic() - started) * 1000, 1), 'error': error}


def publish_status(token, color, results):
    # Check and publish under the same lock that registers new generations.
    with open(LOCK_FILE + '.request', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if is_latest(token):
            write_atomic(os.path.join(os.path.dirname(ACCENT_STATE), 'accent-sync.json'),
                         json.dumps({'token': token, 'color': color, 'targets': results}, indent=2) + '\n')


def apply(hex_color, token=None):
    """Write settings briefly under one lock; update live targets independently."""
    errors = []
    try:
        with open(LOCK_FILE, 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            check_latest(token)
            os.makedirs(os.path.dirname(ACCENT_STATE), exist_ok=True)
            write_atomic(ACCENT_STATE, hex_color + '\n')
            errors = apply_files(hex_color, token)
    except Superseded:
        return
    # The file lock is released before cursor generation, RGB acknowledgments,
    # editor RPC or application IPC. A newer wallpaper never queues behind them.
    actions = {
        'kitty': reload_kitty, 'border': update_border,
        'quickshell': update_quickshell, 'cursor': update_cursor,
        'rgb': update_rgb, 'neovim': update_neovim,
        'opencode': reload_opencode, 'btop': reload_btop,
    }
    results = {name: {'status': 'pending'} for name in actions}
    results['settings'] = {'status': 'error' if errors else 'ok', 'errors': errors}
    publish_status(token, hex_color, results)
    with ThreadPoolExecutor(max_workers=len(actions)) as executor:
        jobs = {executor.submit(run_target, name, action, hex_color, token): name
                for name, action in actions.items()}
        for future in as_completed(jobs):
            results[jobs[future]] = future.result()
            publish_status(token, hex_color, results)


def main():
    parser = argparse.ArgumentParser(description='Sync desktop accents to the accepted wallpaper.')
    parser.add_argument('image', nargs='?')
    parser.add_argument('-d', '--dry-run', action='store_true')
    parser.add_argument('--claim-token', action='store_true', help=argparse.SUPPRESS)
    parser.add_argument('--token', help=argparse.SUPPRESS)
    parser.add_argument('--warm-cache', action='store_true', help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.claim_token:
        print(claim_token())
        return
    if args.warm_cache:
        if not args.image:
            parser.error('--warm-cache requires an image')
        extract_color_cached(args.image)
        return
    token = None if args.dry_run else (args.token or claim_token())
    if not args.dry_run and not is_latest(token):
        return
    try:
        image = args.image or current_wallpaper()
        if image and not os.path.isfile(image):
            raise FileNotFoundError(f'no such wallpaper: {image}')
        # A daemon that is not ready must not overwrite a saved accent with grey.
        if not image and not args.dry_run:
            log_message(f'{token} wallpaper unavailable; kept the existing accent')
            return
        hex_color, reason = (extract_color(image) if args.dry_run else extract_color_cached(image)) if image else (PLATINUM, 'no wallpaper detected')
        if args.dry_run:
            print(f"{image or '-'}: #{hex_color} ({reason})")
        else:
            apply(hex_color, token)
    except Exception as error:
        if not args.dry_run:
            log_message(f'{token} sync: {error}')
        raise


if __name__ == '__main__':
    main()
