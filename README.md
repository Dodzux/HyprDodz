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

Replace `YOUR_USERNAME/YOUR_REPO` with your personal repository.

```sh
sudo pacman -S --needed chezmoi git
chezmoi init YOUR_USERNAME/YOUR_REPO
chezmoi diff
chezmoi apply
~/.local/share/chezmoi/scripts/bootstrap.sh
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

Create an empty repository first. This checkout still has the original
reference remote; replace it with your own URL before pushing.

```sh
cd ~/.local/share/chezmoi
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
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
