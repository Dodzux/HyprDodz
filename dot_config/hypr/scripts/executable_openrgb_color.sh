#!/usr/bin/env bash
# Independent device locks, bounded retries, and generation-aware updates.
set -u
hex="${1:-}"
hex="${hex#\#}"
[[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]] || { echo "usage: $0 RRGGBB [TOKEN]" >&2; exit 2; }
hex="${hex^^}"
token="${2:-}"
script_dir=$(dirname -- "$0")
runtime="${XDG_RUNTIME_DIR:-/tmp}"
state="$runtime/wallpaper-rgb"
# This lock also registers theme generations; an old delayed child cannot
# overwrite the device request published for a newer wallpaper.
exec 8> "$runtime/sync_border.lock.request"
flock 8
[[ -z "$token" || "$(cat "$runtime/sync_border.token" 2>/dev/null)" == "$token" ]] || exit 0
printf '%s\n' "$hex" > "$state.want.$$"
mv -- "$state.want.$$" "$state.want"
flock -u 8
exec 8>&-
still_current() {
    [[ -z "$token" || "$(cat "$runtime/sync_border.token" 2>/dev/null)" == "$token" ]] &&
    [[ "$(cat "$state.want" 2>/dev/null)" == "$hex" ]]
}
board=$(cat /sys/class/dmi/id/board_name 2>/dev/null)
if [[ "$board" != G614PH ]]; then
    still_current || exit 0
    exec "$script_dir/openrgb_color.sh.before-g614ph" "$hex"
fi
"$script_dir/openrgb_mouse_color.sh" "$hex" "$token" &
mouse_pid=$!
exec 9> "$state.keyboard.lock"
flock 9
keyboard_status=0
if still_current; then
    # The stored color is a previous successful write, not hardware readback.
    # Always reapply so reconnects, sleep, and factory-mode resets recover.
    keyboard_status=1
    for attempt in 1 2 3; do
        still_current || { keyboard_status=0; break; }
        if timeout 2s python3 "$script_dir/asus_keyboard_color.py" "$hex"; then
            if still_current; then
                printf '%s\n' "$hex" > "$state.keyboard.applied.$$"
                mv -- "$state.keyboard.applied.$$" "$state.keyboard.applied"
            fi
            keyboard_status=0
            break
        fi
        [[ "$attempt" == 3 ]] || sleep 0.08
    done
fi
flock -u 9
exec 9>&-
mouse_status=0
wait "$mouse_pid" || mouse_status=$?
[[ "$keyboard_status" == 0 ]] || { echo "Keyboard accent failed after three attempts" >&2; exit "$keyboard_status"; }
exit "$mouse_status"
