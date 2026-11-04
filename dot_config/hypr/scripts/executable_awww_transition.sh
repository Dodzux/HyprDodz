#!/usr/bin/env bash
# One temporary worker finishes each transition and drains the newest request.
set -u
script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
wallpaper_dir="$HOME/Pictures/Wallpapers"
image="${1:-}"
[[ -z "$image" || -f "$image" ]] || exit 1
state="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-transition"
request="$$-$EPOCHREALTIME"

# Register before querying/decoding images. Busy callers leave their request
# and exit instead of building a queue of blocked launcher processes.
exec 8> "$state.request.lock"
flock 8
printf '%s\0%s\0' "$request" "$image" > "$state.want.$$"
mv -- "$state.want.$$" "$state.want"
exec 9> "$state.apply.lock"
if ! flock -n 9; then
    exit 0
fi
flock -u 8

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
mkdir -p -- "$log_dir"
accepted=""
synced=""
recovered=false
is_current() {
    local latest
    IFS= read -r -d '' latest < "$state.want"
    [[ "$latest" == "$request" ]]
}
wallpaper_error() {
    printf '%(%F %T)T wallpaper: %s\n' -1 "$1" >> "$log_dir/accent-sync.log"
    if is_current; then
        notify-send Wallpaper "$1" 2>/dev/null || :
    fi
}
sync_accepted() {
    [[ -n "$accepted" && "$accepted" != "$synced" ]] || return 0
    local token
    token=$(timeout -k 1s 3s python3 "$script_dir/sync_border.py" --claim-token 8>&- 9>&-) || return 1
    python3 "$script_dir/sync_border.py" --token "$token" "$accepted" >> "$log_dir/accent-sync.log" 2>&1 8>&- 9>&- &
    synced="$accepted"
}
# Once a snapshot is read, finish it. Rechecking freshness during every
# preparation step would starve transitions under continuous key repeat.
# The next loop drains the newest pending snapshot after this one settles.
apply_wallpaper() {
    local current monitors outputs fps effect result
    local effects=(grow outer wipe wave left right top bottom)
    local previous="" index next
    # Remember the last completed effect, including across separate workers.
    # Wave also makes the first switch differ from the old three-effect set.
    effect=wave
    if [[ -r "$state.effect" ]]; then IFS= read -r previous < "$state.effect" || :; fi
    for index in "${!effects[@]}"; do
        if [[ "${effects[index]}" == "$previous" ]]; then
            next=$(( (index + 1) % ${#effects[@]} ))
            effect=${effects[next]}
            break
        fi
    done
    current=$(exec 8>&- 9>&-; timeout -k 1s 2s awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -1)
    if [[ -z "$image" ]]; then
        # Choose when applying, so a rapid request cannot choose the image
        # that the preceding transition has just installed.
        IFS= read -r -d '' image < <(find "$wallpaper_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) ! -path "${current:-/none}" -print0 2>/dev/null | shuf -z -n 1) || :
    fi
    [[ -f "$image" ]] || { wallpaper_error "No other wallpaper found in $wallpaper_dir"; return; }
    if [[ "$image" == "$current" ]]; then
        accepted="$image"
        return
    fi
    monitors=$(timeout -k 1s 2s hyprctl monitors -j 2>/dev/null 8>&- 9>&-)
    outputs=$(jq -r '[.[] | select(.disabled != true) | .name] | join(",")' <<< "$monitors" 2>/dev/null)
    [[ -n "$outputs" && "$outputs" != null ]] || { wallpaper_error 'Could not find an active display'; return; }
    fps=$(jq '[.[] | select(.disabled != true) | .refreshRate] | max | floor' <<< "$monitors" 2>/dev/null)
    [[ "$fps" =~ ^[0-9]+$ ]] || fps=60
    # Analyze while awww loads; background children never inherit our locks.
    python3 "$script_dir/sync_border.py" --warm-cache "$image" >> "$log_dir/accent-sync.log" 2>&1 8>&- 9>&- &
    result=0
    timeout -k 1s 15s awww img "$image" --outputs "$outputs" --transition-type "$effect" --transition-fps "$fps" --transition-duration 0.75 --transition-step 90 >> "$log_dir/accent-sync.log" 2>&1 8>&- 9>&- || result=$?
    if (( result != 0 )) && [[ "$recovered" == false ]]; then
        # Recover an unresponsive daemon once, without restarting it for a
        # mere decode error. New requests remain registered during recovery.
        if (( result == 124 || result == 137 )) || ! timeout -k 1s 2s awww query >/dev/null 2>&1 8>&- 9>&-; then
            recovered=true
            if timeout -k 1s 6s systemctl --user restart awww-daemon.service >/dev/null 2>&1 8>&- 9>&-; then
                for _ in {1..20}; do
                    timeout -k 1s 1s awww query >/dev/null 2>&1 8>&- 9>&- && break
                    sleep 0.1
                done
                is_current || return
                result=0
                timeout -k 1s 15s awww img "$image" --outputs "$outputs" --transition-type "$effect" --transition-fps "$fps" --transition-duration 0.75 --transition-step 90 >> "$log_dir/accent-sync.log" 2>&1 8>&- 9>&- || result=$?
            fi
        fi
    fi
    if (( result == 0 )); then
        accepted="$image"
        printf '%s\n' "$effect" > "$state.effect.$$"
        mv -- "$state.effect.$$" "$state.effect"
        # Do not hold the request-registration lock while claiming an accent
        # token: callers must always be able to submit the newest wallpaper.
        if is_current; then sync_accepted || :; fi
        # awww acknowledges before its transition finishes. Let the geometric
        # transition and pending Wayland buffer releases settle before sending
        # another image; requests arriving meanwhile replace the pending one.
        sleep 0.95
    else
        wallpaper_error 'Wallpaper update failed; kept the last accepted wallpaper accent'
    fi
}

while :; do
    # Coalesce an initial burst before decoding a potentially large GIF.
    sleep 0.12
    exec 7< "$state.want"
    IFS= read -r -d '' request <&7
    IFS= read -r -d '' image <&7
    exec 7<&-
    apply_wallpaper
    flock 8
    if ! is_current; then
        flock -u 8
        continue
    fi
    # Finish/check and release while holding the registration lock, so a
    # request arriving as we exit either gets drained or starts a new worker.
    # Sync the last accepted image even if a newer image failed to load.
    sync_accepted || exit 1
    flock -u 9
    exec 9>&-
    flock -u 8
    exec 8>&-
    exit 0
done
