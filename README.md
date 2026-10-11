# HyprDodz

My CachyOS / Hyprland desktop: a custom Quickshell bar, Fish shell, Kitty terminal,
and colors that follow the wallpaper. Managed with [chezmoi](https://www.chezmoi.io/).

![HyprDodz desktop](assets/screenshots/preview.png)

[Setup](docs/setup.md) · [Desktop guide](docs/desktop.md) · [Repo map](docs/repository.md) · [Updating configs](docs/maintenance.md)

## What's included

| Part | What it does | Start here |
| --- | --- | --- |
| Hyprland | Windows, monitors, shortcuts, lock and idle | [Config](dot_config/hypr/) |
| Quickshell | Bar, launcher, notifications and desktop panels | [UI](dot_config/quickshell/) |
| Fish + Starship | Shell and prompt | [Shell](dot_config/fish/) |
| Kitty, Neovim, Yazi | Terminal, editor and file manager | [Repo map](docs/repository.md#application-configs) |
| Themes + wallpapers | GTK/Qt styles, icons, cursors and wallpaper accents | [How colors work](docs/desktop.md#wallpaper-colors) |
| Other app settings | Personal settings for OBS, Micro, Inkscape and more | [Full config map](docs/repository.md#application-configs) |

This is a complete personal config collection. You can use individual files or
restore the desktop on an existing CachyOS / Arch installation.

## Get started

Install Git and chezmoi if needed, then download and inspect the configs:

```bash
sudo pacman -S --needed git chezmoi
chezmoi init Dodzux/HyprDodz
chezmoi diff --exclude=scripts
```

Follow the [setup guide](docs/setup.md) for packages and applying the files.
If GitHub asks you to sign in, use your own account.

## Find your way around

```text
dot_config/          App configs → ~/.config/
dot_local/           Launchers, icons and themes → ~/.local/
dot_themes/          GTK themes → ~/.themes/
Pictures/Wallpapers/ Wallpapers
docs/                Guides and detailed reports
packages/            Package lists
scripts/             Setup and maintenance tools
system/              SDDM files and supplemental settings
```

`dot_` means a leading dot: `dot_config` becomes `.config`. A `.tmpl` file is a
chezmoi template, which fills in values such as your home path or accent color.
The [repo map](docs/repository.md) explains the remaining names and setup hooks.

## Everyday shortcuts

`Super` is the Windows key.

| Shortcut | Action |
| --- | --- |
| `Super + T` | Terminal |
| `Super + E` | File manager |
| `Super + A` | App launcher |
| `Super + Space` | Wallpaper selector |
| `Super + V` | Clipboard history |
| `Super + H` | All shortcuts |
| `Super + L` | Lock screen |

More shortcuts and customization paths are in the [desktop guide](docs/desktop.md).

## Credits

Based on [BodzTH/hyprconfigs](https://github.com/BodzTH/hyprconfigs), adapted for my
hardware, apps and wallpaper colors. Bundled themes and icons retain their
upstream license files.
