#!/usr/bin/env bash
# Do not let a sleeping mouse block the keyboard or screen colors.
set -u
hex="${1:-}"
[[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]] || exit 2
token="${2:-}"
script_dir=$(dirname -- "$0")
runtime="${XDG_RUNTIME_DIR:-/tmp}"
state="$runtime/wallpaper-rgb"
still_current() {
    [[ -z "$token" || "$(cat "$runtime/sync_border.token" 2>/dev/null)" == "$token" ]] &&
    [[ "$(cat "$state.want" 2>/dev/null)" == "$hex" ]]
}
exec 9> "$state.mouse.lock"
flock 9
still_current || exit 0
if pgrep -x openrgb >/dev/null; then
    echo 'Mouse accent skipped: OpenRGB is running; avoiding competing HID writes' >&2
    exit 1
fi
for attempt in 1 2; do
    still_current || exit 0
    if timeout 5s python3 "$script_dir/logitech_mouse_color.py" "$hex"; then
        if still_current; then
            printf '%s\n' "$hex" > "$state.mouse.applied.$$"
            mv -- "$state.mouse.applied.$$" "$state.mouse.applied"
        fi
        exit 0
    fi
    [[ "$attempt" == 2 ]] || sleep 0.12
done
echo 'Mouse accent failed after two attempts' >&2
exit 1
