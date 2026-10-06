# Personal Hyprland dotfiles

My active CachyOS/Arch desktop configuration, managed with chezmoi. Based on
[BodzTH/hyprconfigs](https://github.com/BodzTH/hyprconfigs), updated with my own
configs, themes, scripts, and keybindings.

## Desktop

| Component | Configuration |
| --- | --- |
| Compositor | Hyprland with modular Lua configs and host profiles |
| Bar and panels | QuickShell: launcher, notifications, clipboard, wallpaper selector |
| Terminal | Kitty; Ghostty config also included |
| Shell | Fish with Starship |
| Editor | Neovim with NvChad |
| File manager | Yazi |
| Browser | Brave |
| Wallpaper | awww with wallpaper-derived accent colors |
| Lock and idle | hyprlock and hypridle |
| GTK/Qt | Graphite-Dark, Kvantum, qt6ct |
| Cursor | Bibata-Modern-Ice with generated wallpaper accent variants |

The cursor base and the active Graphite theme assets are included. Generated
cursor variants, wallpaper color state, caches, and app account data are not.
Home paths, wallpaper accents, and the current generated cursor name are
templated so they can follow the destination machine.

## Install on another machine

Personal repository: [Dodzux/HyprDodz](https://github.com/Dodzux/HyprDodz).

```sh
sudo pacman -S --needed chezmoi git
chezmoi init Dodzux/HyprDodz
chezmoi diff
chezmoi apply
~/.local/share/chezmoi/scripts/bootstrap.sh
python3 ~/.local/share/chezmoi/scripts/restore-config-permissions.py
```

Initialization asks for the name shown by the lock screen and greeter and
detects the GPU vendor. Bootstrap upgrades the Arch-based system, installs
the categorized package manifests, configures the SDDM greeter, applies the
dotfiles, and enables session services. It does not configure a bootloader.

Brave (`brave-bin` on this machine) is installed separately; it is not in the
official-repository package manifests. The optional Codex launcher expects a
working `~/.local/bin/codex` installation and uses `~/Projects` by default.
The launcher and desktop entry are included; the Codex installation and its
account data are not.

Hardware profiles live in `~/.config/hypr/hosts/`. The loader selects a profile
by hostname and uses `default.lua` when none matches. Existing desktop and
laptop profiles are included; add a profile named after your new machine to
customize displays, input devices, GPU settings, and optional apps.

RGB scripts include support for the ASUS G614PH keyboard and Logitech G305,
plus a generic OpenRGB fallback. Hardware updates require access to the
relevant HID devices. `openrgb_color.sh.before-g614ph` is retained because the
active RGB script executes it on other boards.

## Configuration coverage

The repository also includes ordinary settings for OpenRGB, Micro, Inkscape,
OBS, Discord, Obsidian, Shelly, KDE/Dolphin, Qalculate, Qt tools, Git, Bash,
Zsh, default applications, systemd user links, and the installed theme assets.

See [CONFIG-COVERAGE.md](CONFIG-COVERAGE.md) for the folder-by-folder comparison.
The audit checks file contents and symlink destinations and detects new files
that have never been added to chezmoi:

```sh
python3 scripts/audit-configs.py --report CONFIG-COVERAGE.md
```

Private browser/account profiles, authentication cookies, GitHub credentials,
OBS WebSocket passwords, caches, generated cursor variants, logs, editor state,
and old backup files stay local. Wallpapers over 100 MiB are excluded by
request, including `hunt-showdown-death-roots.1920x1080_1.gif`.

Some folders use permission mode `0751`, which chezmoi cannot encode with its
standard attributes. The original modes are saved in
`system/user/directory-permissions.json`. After applying the configs, restore
those modes with `python3 scripts/restore-config-permissions.py` (add
`--dry-run` to preview). Native `chezmoi status` can show those directory
permission differences even when the supplemental snapshot matches.
[Chezmoi permission limitations](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/).

Selected ordinary Brave/Firefox preferences are saved separately in
`system/user/browser-preferences.json`. This captures a subset of display,
language, and related preferences; it does not reproduce a complete browser
profile and is not applied automatically. Refresh that snapshot with:

```sh
python3 scripts/user_settings.py
```

GNOME/dconf preferences are saved as a text template in
`system/user/dconf.ini.tmpl`. To restore that snapshot explicitly:

```sh
chezmoi execute-template < system/user/dconf.ini.tmpl | dconf load /
```

## Track changes from the running desktop

To capture edits made directly in your active config files:

```sh
chezmoi status
chezmoi re-add
git -C ~/.local/share/chezmoi diff
```

`re-add` skips templates and does not discover new files. Add new configs
explicitly, and update templated files through `chezmoi edit` while retaining
their template expressions:

```sh
chezmoi add ~/.config/hypr/hosts/your-hostname.lua
chezmoi edit ~/.config/kitty/kitty.conf
```

Review with `chezmoi diff` before applying repository changes. Wallpaper sync
updates the accent state and generated cursor theme; chezmoi templates read
that state rather than saving a fixed wallpaper color.

## Publish to your own Git repository

This checkout points to `https://github.com/Dodzux/HyprDodz.git`. Review the
changes before committing and pushing.

```sh
cd ~/.local/share/chezmoi
git remote set-url origin https://github.com/Dodzux/HyprDodz.git
git add .
git diff --cached --stat
git commit -m "Import my current desktop configs"
git push -u origin HEAD
```

If Git asks for an identity, set `git config user.name` and
`git config user.email` for this checkout before committing.

## Repository layout

| Path | Purpose |
| --- | --- |
| `dot_config/` | Application configs, Hyprland scripts, and QuickShell UI |
| `dot_local/` | Launcher, desktop entry, icons, cursor base, and GTK theme |
| `Pictures/Wallpapers/` | Wallpaper collection |
| `.chezmoitemplates/` | Shared accent and cursor state helpers |
| `packages/` | Categorized package manifests inherited from the base setup |
| `scripts/bootstrap.sh` | Arch-based installation and service setup |
| `system/` | SDDM theme/config and bootloader reference files |
| `assets/screenshots/` | Existing showcase images from the base repository |

`system/`, package manifests, scripts, and repository documentation are ignored
by chezmoi's home-directory deployment. Bootstrap handles SDDM separately;
the Limine files are reference material for the original machine.

## Common keybindings

| Key | Action |
| --- | --- |
| `SUPER + T` | Kitty |
| `SUPER + E` | Yazi |
| `SUPER + B` | Brave |
| `SUPER + C` | Neovim |
| `SUPER + X` | Codex, when its launcher exists |
| `SUPER + O` | Obsidian |
| `SUPER + A` | App launcher |
| `SUPER + F` | Focus the bar |
| `SUPER + Space` | Wallpaper selector |
| `SUPER + V` | Clipboard panel |
| `SUPER + Backspace` | Power menu |
| `SUPER + Shift + W` | Change wallpaper and sync accents |
| `SUPER + Print` | Update, commit, and push the showcase screenshot |

The showcase shortcut uses the checkout's configured Git remote. Configure
your personal remote before using it.
