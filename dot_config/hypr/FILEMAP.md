# File map — ~/.config/hypr

The configuration uses Lua on Hyprland 0.56.2. Read `context.md` for the reasons
behind the session target, native RGB and other compatibility decisions.

`hyprland.lua` loads environment, monitors, appearance, animations, input,
layouts, autostart, keybindings and windowrules in that order. Variables and the
host profile are required by those modules; keep this existing structure.

## Hosts

| File | Purpose |
|---|---|
| `hosts/init.lua` | Selects by `/proc/sys/kernel/hostname`, with a default fallback |
| `hosts/Potat0Mac.lua` | ASUS G614PH: 1920x1200/165 Hz internal display and automatic external displays |
| `hosts/default.lua` | Automatic settings for unknown machines |

Profiles supply `monitors`, `gpu`, `env`, `input`, `apps`, and `devices`.
`hyprdodz` is the username. Deleted host profiles must not be restored by chezmoi.
Potat0Mac keeps the working automatic AMD/NVIDIA GPU selection.

## Modules

| File | Purpose |
|---|---|
| `environment.lua` | Cursor state, toolkits, SSH agent, host GPU/env overrides |
| `monitors.lua` | Applies the host's monitor rules |
| `appearance.lua` | Borders, blur, shadows and opacity |
| `animations.lua` | Normal window and workspace animations |
| `input.lua` | US/Arabic keyboard, touchpad, mouse, gestures and host overrides |
| `layouts.lua` | Layouts, miscellaneous options and session-lock recovery |
| `variables.lua` | App commands and optional Codex launcher |
| `autostart.lua` | Session target, wallpaper restore, accent sync and bounded mouse startup retries |
| `keybindings.lua` | Shortcuts and the runnable Apps/keyboard cheatsheet; Codex is SUPER+X |
| `windowrules.lua` | Window/layer/workspace rules; Brave keeps normal animations |

## Runtime scripts

| File | Purpose |
|---|---|
| `bootstrap.sh` | Links user units and enables the required desktop services; excludes OpenRGB |
| `awww_transition.sh` | Random transitions on explicit active outputs, then generation-aware theme sync |
| `sync_border.py` | Cached wallpaper analysis and latest-generation updates across theme targets |
| `sync_cursor.py` | Cached Bibata cursor accent generation |
| `openrgb_color.sh` | Parallel native G614PH keyboard and mouse updates |
| `openrgb_mouse_color.sh` | Serialized, bounded one-shot native mouse update |
| `asus_keyboard_color.py` | Verified ASUS factory static color; correct control report 6 |
| `logitech_mouse_color.py` | Verified G305 HID++ color update; standard library only |
| `openrgb_color.sh.before-g614ph` | Active generic OpenRGB fallback for other hardware; preserve it |
| `pick_rgb.fish` | Screen color picker calling the same RGB path |
| `build_gtk_theme.py` | Manual rebuild of the Graphite GTK theme for runtime accents |
| `gaming-mode.sh` | Existing optional gaming helper |

## Services and tool configs

`systemd/hyprland-session.target` starts/stops graphical-session.target through
the autostart handlers. Keep those handlers on the installed Hyprland version.
Quickshell, awww and the two clipboard watchers have user units in `systemd/`.
Package-provided hypridle, hyprpolkitagent and the GCR SSH socket are enabled by
bootstrap. The optional OpenRGB unit stays inactive on Potat0Mac.

`hypridle.conf`, `hyprlock.conf` and `hyprtoolkit.conf` use hyprlang, not Lua.
The lock command is defined in hypridle only; lock precedes display blanking.
Accent-bearing files are rewritten at runtime and use chezmoi templates.

Quickshell panels and theme IPC live in `~/.config/quickshell`. Kitty's Codex
notification hook is `~/.config/kitty/notifications.py`; the launcher and desktop
entry live in `~/.local/bin` and `~/.local/share/applications`. Keep their identity
and icon paths consistent.

## Editing and recovery

Edit the live configuration, validate Lua/shell syntax and `hyprctl configerrors`,
then sync only the edited non-template files into chezmoi. Do not run a broad
`chezmoi apply` over newer live changes. Generated accent templates need deliberate
source edits rather than `re-add`. GPU environment edits require a new session.
Unused experiments and superseded backup files are stored in a single archive
under `~/.local/state/hypr/config-backups`, outside the active configuration.
