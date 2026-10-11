# Repository map

This repo holds two things: files chezmoi deploys into your home folder, and
supporting material such as guides, package lists and setup tools.

## Files deployed to your home

| Repository path | Destination | Purpose |
| --- | --- | --- |
| `dot_config/` | `~/.config/` | Desktop and app settings |
| `dot_local/bin/` | `~/.local/bin/` | Personal launchers and helpers |
| `dot_local/share/applications/` | `~/.local/share/applications/` | App launcher entries |
| `dot_local/share/icons/` | `~/.local/share/icons/` | Icons, cursors and custom app icons |
| `dot_local/share/themes/` | `~/.local/share/themes/` | Bundled theme variants |
| `dot_themes/` | `~/.themes/` | GTK themes |
| `dot_icons/` | `~/.icons/` | Default cursor setting |
| `dot_codex/themes/` | `~/.codex/themes/` | Desktop accent theme |
| `Pictures/Wallpapers/` | `~/Pictures/Wallpapers/` | Wallpapers and GIFs |
| Root `dot_*` files | Matching hidden files in `~/` | Bash, Zsh, Git, GTK and NVIDIA settings |

Most files in the repo are bundled theme/icon assets. They make the appearance
reproducible, but you rarely need to edit them. Start in `dot_config/hypr/` or
`dot_config/quickshell/` when changing the desktop.

## Application configs

All the existing app settings are retained. The table groups them by purpose;
the paths remain compatible with chezmoi.

| Purpose | Folders/files under `dot_config/` |
| --- | --- |
| Desktop | `hypr/`, `quickshell/`, `systemd/`, `autostart/`, `uwsm/` |
| Shell and terminals | `fish/`, `starship.toml.tmpl`, `starshipfork.toml`, `kitty/`, `ghostty/` |
| Editors and file tools | `nvim/`, `micro/`, `yazi/`, `inkscape/`, `executable_dolphinrc`, `private_arkrc`, `private_baloofileinformationrc`, `private_kiorc`, `private_trashrc` |
| Appearance | `Kvantum/`, `private_gtk-3.0/`, `gtk-4.0/`, `qt6ct/`, `nwg-look/`, `xsettingsd/`, `executable_kdeglobals`, `QtProject/`, `QtProject.conf.tmpl` |
| Media and monitoring | `obs-studio/`, `mpv/`, `pavucontrol.ini`, `btop/`, `OpenRGB/` |
| Other personal apps | `discord/`, `private_obsidian/`, `private_qalculate/`, `private_VirtualBox/`, `shelly/`, `gh/`, `cachyos/`, `cachyos-hello.json` |
| Desktop defaults and helpers | `mimeapps.list`, `private_user-dirs.dirs`, `scripts/` |

A saved app setting does not imply that bootstrap installs the app. Some folders
are retained personal or legacy settings; the [desktop guide](desktop.md) identifies
the active desktop components.

## Supporting folders

These are excluded from chezmoi's home deployment.

| Path | Purpose |
| --- | --- |
| [docs/](README.md) | Guides, reports and diagnostic records |
| [assets/screenshots/](../assets/screenshots/) | README preview image |
| [packages/](../packages/) | Package lists used by full bootstrap |
| [scripts/](../scripts/) | Bootstrap, screenshot publishing, audits and snapshot tools |
| [system/](../system/) | SDDM files, boot reference and supplemental snapshots |

There are two `bootstrap.sh` scripts: `scripts/bootstrap.sh` performs the full
system setup; `dot_config/hypr/scripts/executable_bootstrap.sh` becomes
`~/.config/hypr/scripts/bootstrap.sh` and sets up desktop user services.

## Chezmoi filename conventions

| Name | Meaning |
| --- | --- |
| `dot_` | Replace the prefix with a leading `.` |
| `private_` | Apply restricted permissions |
| `executable_` | Make the deployed file executable |
| `symlink_` | File contents describe the symbolic-link target |
| `.tmpl` | Render values before deployment |
| `.keep` | Preserve an empty directory in Git; excluded from deployment |

The names encode behavior. Renaming them for appearance can change deployment.
`.chezmoi.toml.tmpl` generates machine-local configuration. `.chezmoitemplates/`
holds shared color/cursor templates. `.chezmoiignore` excludes support files.
`.gitattributes` marks bundled assets as vendored for GitHub's language summary.

The root `run_*` files are setup hooks: one restores recorded directory modes,
and the other reconciles Hyprland user units when their contents change.
`chezmoi apply --exclude=scripts` skips those hooks.

## Supplemental settings

[system/user/](../system/user/) contains snapshots handled separately:

- `browser-preferences.json`: selected display/language preferences, refreshed with `python3 scripts/user_settings.py`; these require manual restoration.
- `dconf.ini.tmpl`: restore explicitly with `chezmoi execute-template < system/user/dconf.ini.tmpl | dconf load /`.
- `directory-permissions.json`: original custom modes, restored by the permission hook or `python3 scripts/restore-config-permissions.py`.

[system/etc/sddm.conf](../system/etc/sddm.conf) and the SDDM theme are installed by
full bootstrap. [system/boot/](../system/boot/) is reference material and is not
installed by bootstrap.

Accounts, tokens, browser sessions, generated cursor copies and caches stay
local. The [coverage report](reports/config-coverage.md) records exclusions and
unmanaged files; an unmanaged file is not automatically something to publish.

[Back to the guides](README.md)
