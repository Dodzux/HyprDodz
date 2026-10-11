# Desktop guide

Hyprland manages windows. Quickshell provides the bar and panels. Fish runs the
shell, Starship draws the prompt, and Kitty is the default terminal. Neovim is
the editor and Yazi is the terminal file manager.

## Change a setting

| Change | Source file or folder |
| --- | --- |
| Shortcuts | [hypr/modules/keybindings.lua](../dot_config/hypr/modules/keybindings.lua) |
| App commands | [hypr/modules/variables.lua](../dot_config/hypr/modules/variables.lua) |
| Borders, gaps and blur | [hypr/modules/appearance.lua](../dot_config/hypr/modules/appearance.lua) |
| Animations | [hypr/modules/animations.lua](../dot_config/hypr/modules/animations.lua) |
| Keyboard, touchpad and mouse | [hypr/modules/input.lua](../dot_config/hypr/modules/input.lua) |
| Monitor and hardware overrides | [hypr/hosts/](../dot_config/hypr/hosts/) |
| Bar widgets | [quickshell/bar/](../dot_config/quickshell/bar/) |
| Desktop panels | [quickshell/panels/](../dot_config/quickshell/panels/) |
| Shared UI colors | [quickshell/Theme.qml](../dot_config/quickshell/Theme.qml) |
| Terminal | [kitty/kitty.conf.tmpl](../dot_config/kitty/kitty.conf.tmpl) |
| Shell aliases | [fish/conf.d/](../dot_config/fish/conf.d/) |

These are paths inside the repository. See [maintenance](maintenance.md) before
editing templates or syncing changes made in `~/.config/`.

## Shortcuts

`Super` is the Windows key. `Super + H` opens the complete shortcut list.

| Shortcut | Action |
| --- | --- |
| `Super + T` | Kitty |
| `Super + E` | Yazi |
| `Super + B` | Brave |
| `Super + C` | Neovim |
| `Super + X` | Codex, if installed |
| `Super + O` | Obsidian |
| `Super + A` | App launcher |
| `Super + F` | Focus the bar |
| `Super + Space` | Wallpaper selector |
| `Super + V` | Clipboard history |
| `Super + Backspace` | Power menu |
| `Super + S` | Scratchpad terminal |
| `Super + N` | Scratchpad notes |
| `Super + Shift + W` | Change wallpaper |
| `Super + Shift + P` | Screen color picker |
| `Super + L` | Lock screen |
| `Print` | Screenshot panel |
| `F11` | Copy a screen region |
| `Super + Print` | Update and publish the README screenshot |

For the README screenshot, close every window first. The showcase script
captures the focused monitor and commits/pushes just the preview image.

## Wallpaper colors

Selecting a wallpaper runs `hypr/scripts/awww_transition.sh`, then
`sync_border.py` chooses an accent. It updates window borders, Quickshell,
GTK/Qt, Kitty, Starship, Yazi and supported RGB devices. `sync_cursor.py`
generates a colored copy of the bundled Bibata cursor.

The current color is saved in `~/.local/state/hypr/accent`. Shared templates in
[.chezmoitemplates/](../.chezmoitemplates/) read that state so applying chezmoi
keeps the selected colors. A fresh machine defaults to `#e5e5e5`.

Preview a wallpaper's accent without applying it:

```bash
~/.config/hypr/scripts/sync_border.py --dry-run ~/Pictures/Wallpapers/your-image.png
```

The `openrgb_color.sh.before-g614ph` file is an active fallback used on other
hardware. Its backup-like name does not mean it is unused. Mouse RGB details
and validation records are in the [documentation index](README.md#detailed-references).

## Hardware profiles

Hyprland reads `hosts/<hostname>.lua`, falling back to `hosts/default.lua`.
`Potat0Mac.lua` is my ASUS G614PH laptop profile. Put monitor, GPU and device
overrides in a host profile so the shared modules remain reusable.

```bash
profile="$(cat /proc/sys/kernel/hostname)"
cp ~/.config/hypr/hosts/default.lua ~/.config/hypr/hosts/"$profile".lua
# Edit the copy, then track it:
chezmoi add ~/.config/hypr/hosts/"$profile".lua
```

Re-run `chezmoi init` after changing GPU hardware to refresh the package choice.
GPU environment changes require a new session. The [Hyprland file map](../dot_config/hypr/FILEMAP.md)
explains the full module and service structure.

[Back to the guides](README.md)
