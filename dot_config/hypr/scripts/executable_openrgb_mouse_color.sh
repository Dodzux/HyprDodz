#!/usr/bin/env bash
# Send mouse colours through the running OpenRGB SDK server.
# Never perform local hardware detection or compete with its HID connection.
set -euo pipefail

hex="${1:-}"
hex="${hex#\#}"
[[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]] || {
    echo "Usage: bash $0 RRGGBB [GENERATION]" >&2
    exit 2
}
hex="${hex^^}"
token="${2:-}"
runtime="${XDG_RUNTIME_DIR:-/tmp}"
state="$runtime/wallpaper-rgb"

still_current() {
    [[ -z "$token" || "$(cat "$runtime/sync_border.token" 2>/dev/null)" == "$token" ]] &&
    [[ "$(cat "$state.want" 2>/dev/null)" == "$hex" ]]
}

exec 9> "$state.mouse.lock"
flock 9
still_current || exit 0

# OpenRGB can write its own config even as a client. Use an isolated directory
# under session runtime storage, never the user's existing ~/.config/OpenRGB.
client_config="$runtime/hypr-mouse-sdk-client"
[[ ! -L "$client_config" ]] || {
    echo 'Mouse SDK config path is a symlink; refusing to use it' >&2
    exit 1
}
mkdir -p -- "$client_config"
# Keep automatic SDK connections enabled: this installation returns no
# devices with --noautoconnect, even when --client is explicitly provided.
client=(openrgb --config "$client_config" --nodetect
        --client 127.0.0.1:6742)

# Some OpenRGB CLI errors return status zero; inspect the response as well.
cli_error() {
    local response="${1,,}"
    [[ "$response" == *"error:"* || "$response" == *"[error]"* ||
       "$response" == *"wrong number of colors specified"* ]]
}

if ! listing=$(timeout 5s "${client[@]}" --list-detailed 2>&1) || cli_error "$listing"; then
    echo 'Mouse accent failed: OpenRGB SDK device query failed' >&2
    exit 1
fi

# A receiver can expose multiple entries. Select only G305 entries and use each
# entry's advertised modes; device details and serials are never logged.
args=()
selected=''
while IFS= read -r line; do
    if [[ "$line" =~ ^([0-9]+):[[:space:]]+(.*)$ ]]; then
        selected=''
        if [[ "${BASH_REMATCH[2]}" == *G305* ]]; then
            selected="${BASH_REMATCH[1]}"
        fi
    elif [[ -n "$selected" && "$line" =~ ^[[:space:]]+Modes: ]]; then
        mode=''
        modes="${line#*Modes:}"
        modes="${modes//[/ }"
        modes="${modes//]/ }"
        modes="${modes//$'\t'/ }"
        if [[ " $modes " == *" Static "* ]]; then
            mode=static
        elif [[ " $modes " == *" Direct "* ]]; then
            mode=direct
        fi
        if [[ -n "$mode" ]]; then
            args+=(--device "$selected" --mode "$mode" --color "$hex")
        fi
        selected=''
    fi
done <<< "$listing"

if (( ${#args[@]} == 0 )); then
    echo 'Mouse accent failed: SDK lists no G305 with Static or Direct mode' >&2
    exit 1
fi
still_current || exit 0
if ! response=$(timeout 5s "${client[@]}" "${args[@]}" 2>&1) || cli_error "$response"; then
    echo 'Mouse accent failed: OpenRGB SDK colour request failed' >&2
    exit 1
fi
# The publisher uses the same request lock. Checking and recording under it
# prevents a newer wallpaper request from racing the success marker write.
exec 8> "$runtime/sync_border.lock.request"
flock 8
if still_current; then
    printf '%s\n' "$hex" > "$state.mouse.applied.$$"
    mv -- "$state.mouse.applied.$$" "$state.mouse.applied"
fi
