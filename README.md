# HyprDodz — CachyOS Hyprland Dotfiles

> My Hyprland desktop on an ASUS ROG Strix G16: modular Lua configs, a custom Quickshell UI, and wallpaper colors shared across the desktop. Managed with chezmoi.

![HyprDodz desktop](assets/screenshots/preview.png)

---

This repo contains my desktop and personal app settings for **CachyOS**. Start with an existing Arch-family installation; the package lists, configs and greeter setup build on that system. The boot configuration under `system/boot/` is reference material.

## Quick Start & Reproduction

Download the configs, inspect the changes, then apply the files you want:

```bash
# 1. Install the dotfile manager
sudo pacman -S --needed chezmoi git

# 2. Download and review
chezmoi init Dodzux/HyprDodz
chezmoi diff --exclude=scripts

# 3. Apply with confirmation; defer the setup hooks
chezmoi apply --interactive --exclude=scripts
```

Initialization asks for the name shown on the lock screen and greeter, and detects the GPU vendor. A machine without a matching host profile uses automatic monitor settings.

Review [packages/](packages/) and install the categories needed for your machine. Some entries use CachyOS packages or may need another package source on Arch. **Brave** is installed separately (`brave-bin` on my machine); optional personal apps such as Codex also need their own installation.

The full [scripts/bootstrap.sh](scripts/bootstrap.sh) can install the package lists and detected GPU stack, upgrade the system, set Fish as the login shell, install the SDDM greeter, enable services and force-apply the saved configs. Review those operations before choosing to run it:

```bash
~/.local/share/chezmoi/scripts/bootstrap.sh
```

For manual setup, the separate `~/.config/hypr/scripts/bootstrap.sh` links and enables the desktop's user services after their packages are installed. The [detailed restore notes](docs/reports/restore-on-new-install.md) cover service setup and RGB device permissions.

---

## System & Application Stack

| Component | Choice | My setup |
| --- | --- | --- |
| Compositor | Hyprland | Modular Lua config, launched directly |
| Greeter | SDDM | Custom `hypr-sddm` theme |
| Bar & panels | Quickshell | QML bar, launcher, clipboard, notifications, overview and wallpaper selector |
| Terminal | Kitty | Default terminal; Ghostty settings are also included |
| Shell | Fish + Starship | Modular shell files and a custom prompt |
| Editor | Neovim + NvChad | Lua configuration, plugins and language tooling |
| File manager | Yazi | Opens inside Kitty |
| Browser | Brave | Default browser on `SUPER + B` |
| Wallpaper | awww | Animated wallpapers and random transitions |
| Lock & idle | hyprlock + hypridle | Lock screen, idle blanking and display power management |
| GTK & Qt | Graphite-Dark + Kvantum + qt6ct | Dark appearance with wallpaper accents |
| Icons & cursor | Tela circle black + Bibata-Modern-Ice | Bundled icons and generated accent cursor variants |
| RGB | Native HID helpers + OpenRGB fallback | ASUS keyboard and Logitech G305 indicator |

### Wallpaper accents

`hypr/scripts/sync_border.py` runs at login, on config reload and after wallpaper changes. It selects an accent from the image and updates Hyprland, the lock screen, Quickshell, GTK/Qt, Kitty, Starship, Yazi and supported RGB devices. `sync_cursor.py` generates a separate colored Bibata cursor theme.

Shared templates read the saved color from `~/.local/state/hypr/accent`, so applying the repo keeps the current wallpaper colors. A fresh machine starts with `#e5e5e5` and the base Bibata cursor. Select a wallpaper with `SUPER + Space` to generate the color state.

```bash
# Preview a wallpaper's accent without applying it
~/.config/hypr/scripts/sync_border.py --dry-run ~/Pictures/Wallpapers/your-image.png
```

Accent-bearing configs are templates: `chezmoi re-add` skips them. Edit their source with `chezmoi edit` and retain the template expressions.

---

## Hardware & Portability

### My machine

| Part | Hardware / configuration |
| --- | --- |
| Laptop | ASUS ROG Strix G16 G614PH |
| CPU | AMD Ryzen 9 8940HX |
| GPUs | NVIDIA GeForce RTX 5050 Laptop GPU + AMD Radeon 610M |
| Host profile | `Potat0Mac.lua` |
| Internal display | `eDP-1`, 1920×1200 at 165 Hz, scale 1 |
| External displays | Preferred mode, automatic placement |
| Keyboard | US / Arabic; switch with `SUPER + K` |
| Touchpad | Natural scrolling, tap to click, disabled while typing |
| Mouse | Logitech G305 with wallpaper-driven indicator color |

### Host profiles

[hosts/init.lua](dot_config/hypr/hosts/init.lua) loads the profile matching the machine's hostname. The username is separate from the hostname. Unrecognized machines use `default.lua`.

```text
~/.config/hypr/hosts/
├── init.lua          # Profile loader
├── default.lua       # Automatic settings for other machines
└── Potat0Mac.lua      # My ASUS G614PH laptop
```

Profiles hold monitor rules, input/device overrides, app commands and optional GPU environment settings. To add your machine:

```bash
profile="$(cat /proc/sys/kernel/hostname)"
cp ~/.config/hypr/hosts/default.lua ~/.config/hypr/hosts/"$profile".lua
# Edit the new profile, then save it into chezmoi:
chezmoi add ~/.config/hypr/hosts/"$profile".lua
```

### GPU selection

My profile leaves `gpu` and `env` empty because automatic selection works on this AMD/NVIDIA hybrid laptop. Other profiles can specify GPU PCI addresses and environment overrides; [modules/environment.lua](dot_config/hypr/modules/environment.lua) resolves the addresses to DRM devices at startup.

Package selection is separate: `chezmoi init` detects NVIDIA, AMD or Intel and saves that choice locally. Bootstrap installs the matching `80-gpu-*.txt` list. NVIDIA takes precedence on my hybrid machine; this is not a complete driver prescription for every hybrid system. Review the lists against your OS and re-run initialization after changing hardware.

### Keyboard & mouse lighting

On the G614PH, native helpers update the ASUS keyboard and G305 indicator independently. Updates use bounded retries and wallpaper-generation checks. Mouse startup retries handle delayed wireless wake-up; an existing OpenRGB process causes mouse updates to be deferred.

The OpenRGB package supplies device access rules. Reconnect the devices or reboot after installation, and run the helpers as your normal user. The desktop service helper excludes the OpenRGB server. Other board models use `openrgb_color.sh.before-g614ph`, which is an active fallback despite its backup-like name.

The [native RGB review](docs/reports/native-mouse-upload-review.md) records the supported hardware and verification limits. Run the hardware-free routing checks with `python3 scripts/test-mouse-rgb.py`.

---

## Categorized Package Manifests

The full bootstrap reads [packages/](packages/). App settings and package installation are separate: the repository retains more personal configs than the manifests install.

| Manifest | Contents |
| --- | --- |
| `10-hyprland.txt` | Hyprland, Quickshell, awww, lock/idle tools, screenshots and desktop daemons |
| `20-apps.txt` | Neovim, Micro, Firefox, Obsidian, OBS, Inkscape, OpenRGB and other apps |
| `30-shell.txt` | Fish, Starship, Yazi, Git/GitHub CLI and command-line tools |
| `40-terminals.txt` | Kitty and Ghostty |
| `50-fonts.txt` | Noto, emoji, UI fonts and Cascadia Code Nerd Font |
| `60-audio-media.txt` | PipeWire, WirePlumber, ALSA and media codecs |
| `70-theming.txt` | GTK/Qt tooling, Kvantum, qt6ct and Tela icons |
| `80-gpu-amd.txt` / `80-gpu-intel.txt` / `80-gpu-nvidia.txt` | Vendor-specific GPU packages |
| `90-networking.txt` | NetworkManager, Bluetooth, OpenSSH and firewall tools |
| `95-extra.txt` | Additional desktop utilities |

Firefox remains in the application list; Brave is the configured browser. Theme assets are bundled in the repo, while bootstrap can fetch Graphite-Dark if it is missing.

---

## Keybinding Highlights

`SUPER` is the Windows key. Press `SUPER + H` for the complete interactive shortcut list.

| Shortcut | Action |
| --- | --- |
| `SUPER + T` | Kitty terminal |
| `SUPER + E` | Yazi file manager |
| `SUPER + B` | Brave browser |
| `SUPER + C` | Neovim |
| `SUPER + X` | Codex, when its launcher is available |
| `SUPER + O` | Obsidian |
| `SUPER + U` | System updater (`pacman -Syu` in Kitty) |
| `SUPER + A` | App launcher |
| `SUPER + F` | Focus the bar |
| `SUPER + Space` | Wallpaper selector |
| `SUPER + V` | Clipboard history |
| `SUPER + Backspace` | Power menu |
| `SUPER + S` / `SUPER + N` | Scratchpad terminal / notes |
| `SUPER + K` | Switch US / Arabic keyboard layout |
| `SUPER + Shift + W` | Random wallpaper and accent sync |
| `SUPER + Shift + P` | Screen color picker |
| `SUPER + L` | Lock screen |
| `Print` | Quickshell screenshot panel |
| `F11` | Screen region to clipboard |
| `F12` | Screen region to Satty for annotation |
| `SUPER + Print` | Capture and publish the README preview |

Change shortcuts in [modules/keybindings.lua](dot_config/hypr/modules/keybindings.lua) and app commands in [modules/variables.lua](dot_config/hypr/modules/variables.lua). The optional Codex launcher opens in `~/Codex` by default and resumes the last session when launched without arguments.

---

## System Files

[system/](system/) is excluded from chezmoi's home deployment. It holds the greeter files and supplemental references:

```text
system/
├── etc/sddm.conf
├── usr/share/sddm/themes/hypr-sddm/
├── boot/limine.conf.header
└── user/
    ├── browser-preferences.json
    ├── dconf.ini.tmpl
    └── directory-permissions.json
```

Bootstrap installs the SDDM config/theme and copies `street.gif` and `black_bg.jpg` from the wallpaper folder into the greeter. The display name is written to `theme.conf.user`. The Limine header is retained as a reference; bootstrap does not write it to `/boot`.

`system/user/` contains selected browser preferences, a dconf text snapshot and custom directory modes. Browser preferences require manual restoration; restore dconf explicitly with `chezmoi execute-template < system/user/dconf.ini.tmpl | dconf load /`. The directory-mode hook runs after a normal apply; preview it with `python3 scripts/restore-config-permissions.py --dry-run`.

---

## Dotfiles Management

```bash
# Compare live files with the saved configs
chezmoi status
chezmoi diff

# Edit a saved config, preserving its template expressions
chezmoi edit ~/.config/kitty/kitty.conf

# Save changes from existing live files (skips templates)
chezmoi re-add

# Track a new file
chezmoi add ~/.config/newapp/config

# Refresh machine data and GPU detection
chezmoi init

# Review before applying the saved configs
chezmoi apply --interactive

# Review, commit and push repository changes
cd ~/.local/share/chezmoi
git diff --check
git diff
# Example: stage the shortcut file after reviewing its changes
git add dot_config/hypr/modules/keybindings.lua
git diff --cached --stat
git commit -m "Update desktop configs"
git push
```

Save newer live edits before applying the whole repository. `dot_`, `private_`, `executable_`, `symlink_` and `.tmpl` are chezmoi attributes: they describe names, permissions, links and rendering rather than arbitrary folder labels.

### Repository layout

| Path | Contents |
| --- | --- |
| `dot_config/hypr/` | Hyprland modules, host profiles, scripts and user units |
| `dot_config/quickshell/` | Bar, panels and shared UI theme |
| Other `dot_config/` folders | Fish, Kitty, Neovim, Yazi and personal app settings |
| `dot_local/` | Launchers, desktop entries, icons, cursors and theme variants |
| `dot_themes/` | GTK theme assets |
| `Pictures/Wallpapers/` | Wallpapers and GIFs |
| `.chezmoitemplates/` | Shared accent and cursor templates |
| `packages/` | Package manifests |
| `scripts/` | Full bootstrap, showcase capture, audits and snapshot helpers |
| `system/` | Greeter and supplemental settings |
| `docs/reports/` | Detailed restore and verification records |
| `assets/screenshots/` | Desktop preview |

All existing app configs are kept, including OBS, Micro, Inkscape, Discord, Obsidian, OpenRGB, Qt/KDE tools and Git. Most repository files are bundled icons and themes; desktop customization starts in `dot_config/hypr/` and `dot_config/quickshell/`.

Accounts, credentials, browser sessions, caches, generated accent cursors and oversized wallpapers stay local. The [coverage report](docs/reports/config-coverage.md) records the last comparison with live files. Refresh it from the repo root with:

```bash
python3 scripts/audit-configs.py --report docs/reports/config-coverage.md
```

---

## Updating the Showcase Screenshot

Close every window, then press `SUPER + Print`. [scripts/showcase.sh](scripts/showcase.sh) captures the focused monitor into `assets/screenshots/preview.png`, commits that image and pushes it to the configured remote. It requires working GitHub authentication and refuses to capture while windows are open.

---

## Credits

Based on [BodzTH/hyprconfigs](https://github.com/BodzTH/hyprconfigs), adapted for my ASUS laptop, apps, wallpaper accents and RGB hardware. Bundled themes and icons retain their upstream license files.
