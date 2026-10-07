#!/usr/bin/env bash
# One-shot native mouse update; no SDK client, detection daemon or restart.
set -euo pipefail
hex="${1:-}"
hex="${hex#\#}"
[[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]] || { echo 'Expected RRGGBB [GENERATION]' >&2; exit 2; }
hex="${hex^^}"
token="${2:-}"
runtime="${XDG_RUNTIME_DIR:-/tmp}"
state="$runtime/wallpaper-rgb"
script_dir=$(dirname -- "$0")

still_current() {
    [[ -z "$token" || "$(cat "$runtime/sync_border.token" 2>/dev/null)" == "$token" ]] &&
    [[ "$(cat "$state.want" 2>/dev/null)" == "$hex" ]]
}

exec 9> "$state.mouse.lock"
flock 9
still_current || exit 0
# A second hardware owner could overwrite colours or consume HID replies.
if pgrep -x openrgb >/dev/null; then
    echo 'Mouse accent deferred: OpenRGB is using the receiver' >&2
    exit 1
fi
timeout 3s python3 "$script_dir/logitech_mouse_color.py" "$hex"

# Only acknowledge the current generation, after both HID writes succeeded.
exec 8> "$runtime/sync_border.lock.request"
flock 8
if still_current; then
    printf '%s\n' "$hex" > "$state.mouse.applied.$$"
    mv -- "$state.mouse.applied.$$" "$state.mouse.applied"
fi
