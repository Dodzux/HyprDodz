# HyprDodz — CachyOS Hyprland Dotfiles

> My Hyprland desktop with QuickShell, Fish, Kitty, and accents that follow the wallpaper. Managed with **chezmoi** and modular **Lua** configs.

## Showcase

![HyprDodz desktop showcase](assets/screenshots/preview.png)

[Quick start](#quick-start--reproduction) · [Desktop stack](#system--application-stack) · [Hardware profiles](#hardware-portability) · [Keybindings](#keybinding-highlights) · [Manage configs](#dotfiles-management) · [Coverage](#configuration-coverage--extra-settings)

---

## Quick Start & Reproduction

Start with a working **CachyOS or Arch installation** and restore the user
configuration in stages. The private repository requires your own GitHub
authentication; account credentials are never part of the dotfiles.

```bash
# Install Git and chezmoi yourself if they are missing:
# sudo pacman -S --needed chezmoi git

# Download only; inspect the changes before deployment.
chezmoi init Dodzux/HyprDodz
chezmoi diff --exclude=scripts

# Confirm each config change; defer automatic setup hooks.
chezmoi apply --interactive --exclude=scripts
```

See [restoring on a new installation](assets/reports/restore-on-new-install.md)
for package installation, desktop user units, wallpaper selection, and mouse
permissions. Chezmoi restores the saved home-directory files; packages, device
access, and a working graphical session must also be available.

The existing `scripts/bootstrap.sh` performs a full system upgrade, GPU package
installation, SDDM setup, shell changes, service enablement, and a forced config
apply. Review it before choosing to run it. The staged restore above does not
run that script or chezmoi setup hooks.

Initialization asks for the display name used by the lock screen and greeter
and detects the GPU vendor. Review these machine-local choices on a new host.

**Brave is installed separately** (`brave-bin` on my machine); it is the browser
configured for `SUPER + B`. The optional Codex shortcut requires your own
`~/.local/bin/codex` installation. Their account data is not included.

---

## System & Application Stack

| Component | Choice | Configuration |
| --- | --- | --- |
| Compositor | [Hyprland](https://hyprland.org/) | Modular Lua config with host profiles |
| Greeter | [SDDM](https://github.com/sddm/sddm) | Custom `hypr-sddm` theme |
| Bar & panels | [QuickShell](https://quickshell.org/) | Workspaces, system tray, launcher, clipboard, notifications, and wallpaper selector |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) | Default terminal; Ghostty config also included |
| Shell | [Fish](https://fishshell.com/) + [Starship](https://starship.rs/) | Modular shell setup and my custom prompt |
| Editor | [Neovim](https://neovim.io/) + [NvChad](https://nvchad.com/) | Lua settings, plugins, and language tooling |
| File manager | [Yazi](https://yazi-rs.github.io/) | Terminal file manager |
| Browser | [Brave](https://brave.com/) | Default browser and URL handler |
| Wallpaper | [awww](https://github.com/awww-project/awww) | Animated wallpapers and transitions |
| Lock & idle | hyprlock + hypridle | Lock screen, screen blanking, and DPMS |
| GTK & Qt | Graphite-Dark, Kvantum, qt6ct | Dark theme and rounded UI styling |
| Cursor | Bibata-Modern-Ice | Xcursor/Hyprcursor base with generated accent variants |
| RGB | Native HID helpers + OpenRGB fallback | ASUS G614PH keyboard and Logitech G305 indicator |

### Wallpaper accents

`~/.config/hypr/scripts/sync_border.py` updates the desktop accent when the wallpaper changes. The color is used by Hyprland, the lock screen, QuickShell, GTK/Qt, Kitty, Starship, Yazi, and supported RGB devices. `sync_cursor.py` creates a separate colored Bibata cursor theme.

Shared chezmoi templates read the current accent and cursor state under `~/.local/state/hypr/`, so restoring the configs keeps the current wallpaper colors. A new machine starts with the `#e5e5e5` accent and the Bibata-Modern-Ice base cursor.

Preview the color selected from an image:

```bash
~/.config/hypr/scripts/sync_border.py --dry-run ~/Pictures/Wallpapers/your-image.png
```

The theme and icon assets are included in the repository. Generated cursor copies are kept local.

---

## Hardware Portability

### Host profiles

Hyprland loads a profile matching the machine hostname from `~/.config/hypr/hosts/`. When there is no matching profile, it uses `default.lua` with automatic monitor settings.

```text
~/.config/hypr/hosts/
├── init.lua           # Hostname lookup and profile loader
├── default.lua        # Fallback profile
└── Potat0Mac.lua      # ASUS G614PH laptop: native panel + external displays
```

To configure another machine, copy the default profile and edit its monitor, input, GPU, or app settings:

```bash
profile="$(cat /proc/sys/kernel/hostname)"
cp ~/.config/hypr/hosts/default.lua ~/.config/hypr/hosts/"$profile".lua
chezmoi add ~/.config/hypr/hosts/"$profile".lua
chezmoi edit ~/.config/hypr/hosts/"$profile".lua
```

Alternatively, edit it directly in your editor and then run `chezmoi add`.

### GPU and personal apps

`chezmoi init` detects AMD, Intel, or NVIDIA hardware and saves the vendor in its machine-local configuration. Bootstrap selects the matching `80-gpu-*.txt` manifest. Re-run `chezmoi init` after changing GPUs.

Potat0Mac explicitly configures its native 1920x1200/165 Hz panel and leaves GPU selection automatic for its working AMD/NVIDIA hybrid setup. Host profiles can also specify GPU addresses and environment variables when needed. The default profile leaves GPU selection automatic. Home paths are filled in by templates, while optional apps such as Codex are configured separately. The Codex launcher starts in `~/Projects` by default.

Hardware RGB helpers need access to the corresponding HID devices. The file `openrgb_color.sh.before-g614ph` is retained because the active script uses it as the generic OpenRGB fallback.

The G305 indicator uses a one-shot native HID helper on the ASUS G614PH path.
It verifies the receiver and lighting feature before writing, uses a three-second
timeout, and only records success for the current wallpaper generation. If
OpenRGB is already running, the update is deferred to avoid competing receiver
access. Startup retries cover a mouse that wakes after the first accent update;
there is no permanent polling loop. The Hyprland user-unit setup no longer
includes the OpenRGB server, and importing these files does not stop an existing
server. Other machines retain the generic OpenRGB fallback.

Run the hardware-free checks with `python3 scripts/test-mouse-rgb.py`. The test
runner supports both the native and earlier SDK wrappers; see the
[upload verification report](assets/reports/native-mouse-upload-review.md) for
this change and the limits of the checks.

---

## Categorized Package Manifests

Bootstrap reads the lists in `packages/`:

| Manifest | Purpose |
| --- | --- |
| `10-hyprland.txt` | Hyprland tools, QuickShell, SDDM, screen capture, and desktop daemons |
| `20-apps.txt` | Applications including Neovim, Micro, OBS, Obsidian, Inkscape, and OpenRGB |
| `30-shell.txt` | Fish, Git/GitHub CLI, Starship, Yazi, and command-line tools |
| `40-terminals.txt` | Kitty and Ghostty |
| `50-fonts.txt` | UI fonts, Noto, emoji, and Cascadia Code Nerd Font |
| `60-audio-media.txt` | PipeWire, WirePlumber, ALSA, and media codecs |
| `70-theming.txt` | GTK/Qt theming tools and supporting packages |
| `80-gpu-amd.txt` / `80-gpu-intel.txt` / `80-gpu-nvidia.txt` | GPU packages; only the detected vendor is installed |
| `90-networking.txt` | NetworkManager, Bluetooth, OpenSSH, and firewall tools |
| `95-extra.txt` | Additional desktop utilities |

Brave and the Codex installation are outside these manifests. Additional app settings included in the snapshot do not imply that every corresponding application is installed by bootstrap.

---

## Keybinding Highlights

| Key | Action |
| --- | --- |
| `SUPER + T` | Open Kitty |
| `SUPER + E` | Open Yazi |
| `SUPER + B` | Open Brave |
| `SUPER + C` | Open Neovim |
| `SUPER + X` | Open Codex, when its launcher exists |
| `SUPER + O` | Open Obsidian |
| `SUPER + A` | Toggle app launcher |
| `SUPER + F` | Focus the bar |
| `SUPER + Space` | Toggle wallpaper selector |
| `SUPER + V` | Toggle clipboard history |
| `SUPER + H` | Open the keybinding cheatsheet |
| `SUPER + Backspace` | Toggle power menu |
| `SUPER + S` | Toggle scratchpad terminal |
| `SUPER + N` | Toggle scratchpad notes |
| `SUPER + Shift + W` | Change wallpaper and sync accents |
| `SUPER + Shift + P` | Pick an RGB color from the screen |
| `SUPER + L` | Lock the session |
| `Print` | Open screenshot panel |
| `F11` | Copy a selected screen region |
| `SUPER + Print` | Capture and publish the README showcase |

The full bindings are in [`modules/keybindings.lua`](dot_config/hypr/modules/keybindings.lua) and the desktop cheatsheet.

---

## System Files

Chezmoi deploys the home-directory configs. Files that belong elsewhere are kept under `system/` and excluded from that deployment:

```text
system/
├── etc/sddm.conf
├── boot/limine.conf.header
├── usr/share/sddm/themes/hypr-sddm/
└── user/
    ├── browser-preferences.json
    ├── dconf.ini.tmpl
    └── directory-permissions.json
```

Bootstrap installs the SDDM config/theme and copies its backgrounds from `Pictures/Wallpapers/`. The greeter header uses the display name provided during chezmoi initialization.

The Limine file is reference material from the base setup. Bootstrap does not write to `/boot` or install a bootloader. The files under `system/user/` are supplemental personal settings, described below.

---

## Dotfiles Management

```bash
# Compare the running configs with the repository
chezmoi status
chezmoi diff

# Pull edits from already tracked files into the repository
chezmoi re-add

# Add a new configuration file
chezmoi add ~/.config/newapp/config

# Edit a managed file, preserving its template expressions
chezmoi edit ~/.config/kitty/kitty.conf

# Apply the repository's configs to this machine
chezmoi apply

# Refresh the display name and GPU detection
chezmoi init
```

`chezmoi re-add` skips templates and does not discover new files. Use `chezmoi edit` for templated settings and `chezmoi add` for new files.

Check complete folder coverage, including files that have never been added:

```bash
cd ~/.local/share/chezmoi
python3 scripts/audit-configs.py --report CONFIG-COVERAGE.md
```

Commit and push updates to [Dodzux/HyprDodz](https://github.com/Dodzux/HyprDodz):

```bash
cd ~/.local/share/chezmoi
git add .
git diff --cached --stat
git commit -m "Update my desktop configs"
git push
```

---

## Updating the Showcase Screenshot

Close all windows, then press **`SUPER + Print`**. [`scripts/showcase.sh`](scripts/showcase.sh) captures the focused monitor into `assets/screenshots/preview.png`, commits that image, and pushes it to the configured Git remote. It refuses to capture while any windows are open.

The README displays that file directly, so updating the image updates the showcase. The screenshot commit contains only the preview image. GitHub authentication must already be configured for the push.

---

## Configuration Coverage & Extra Settings

The repository also contains ordinary settings for OpenRGB, Micro, Inkscape, OBS, Discord, Obsidian, Shelly, KDE/Dolphin, Qalculate, Qt tools, Git, Bash, Zsh, default applications, and systemd user services. See the [coverage report](CONFIG-COVERAGE.md) for the folder comparison and recorded exceptions.

Private account/browser profiles, authentication cookies, GitHub credentials, OBS WebSocket passwords, caches, generated cursor variants, logs, and old backups stay local. Wallpapers above 100 MiB are excluded, including `hunt-showdown-death-roots.1920x1080_1.gif`.

### Custom directory permissions

Some folders use `0751`, which chezmoi's standard attributes cannot encode. Their original modes are recorded in `system/user/directory-permissions.json` and restored automatically after `chezmoi apply` and by bootstrap. To restore those modes manually:

```bash
python3 ~/.local/share/chezmoi/scripts/restore-config-permissions.py
```

Add `--dry-run` to preview. Native `chezmoi status` can show these permission differences even when the supplemental snapshot matches. The coverage report lists any malformed symlink targets that chezmoi normalizes.

### Browser preferences and dconf

`system/user/browser-preferences.json` holds selected ordinary Brave/Firefox display and language preferences. It is a partial settings snapshot, is not applied automatically, and contains no complete browser profile. Refresh it with:

```bash
python3 scripts/user_settings.py
```

GNOME/dconf settings are captured as a text template. Restore them explicitly with:

```bash
chezmoi execute-template < system/user/dconf.ini.tmpl | dconf load /
```

### Repository layout

| Path | Contents |
| --- | --- |
| `dot_config/` | App configs, Hyprland modules/scripts, and QuickShell UI |
| `dot_local/` | Launchers, desktop entries, icons, cursors, and themes |
| `dot_themes/` | GTK theme assets under `~/.themes` |
| `Pictures/Wallpapers/` | Wallpapers and GIFs within the file-size limit |
| `.chezmoitemplates/` | Shared accent and cursor templates |
| `packages/` | Package lists used by bootstrap |
| `scripts/` | Bootstrap, showcase capture, audits, and snapshot helpers |
| `system/` | Greeter files, boot reference, and supplemental settings |
| `assets/screenshots/` | Desktop showcase image |

Names such as `dot_config`, `private_`, `executable_`, and `.tmpl` are chezmoi source attributes. Chezmoi converts them to the normal names when applying the configs.

---

Based on [BodzTH/hyprconfigs](https://github.com/BodzTH/hyprconfigs), adapted for my own desktop and configs.
