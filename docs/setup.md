# Setup

Start with an existing CachyOS / Arch installation. These files restore your
user configuration; desktop packages and a working graphical session are also
needed. Review changes and back up existing configs before applying them.

Run repository commands below from `~/.local/share/chezmoi`.

## 1. Download and inspect

```bash
sudo pacman -S --needed git chezmoi
chezmoi init Dodzux/HyprDodz
chezmoi diff --exclude=scripts
```

Initialization asks for the display name used by the lock screen and greeter,
and detects the GPU vendor. Unknown hostnames use automatic monitor settings.

## 2. Choose packages

Review the lists in [packages/](../packages/). Install the categories you need
through your package manager; choose only the GPU list matching your hardware.
Some packages may require CachyOS repositories or another package source on Arch.

| List | Contents |
| --- | --- |
| `10-hyprland.txt` | Compositor, Quickshell, wallpaper and screenshot tools |
| `20-apps.txt` | Editors and personal applications |
| `30-shell.txt` | Fish, Starship and command-line tools |
| `40-terminals.txt` | Kitty and Ghostty |
| `50-fonts.txt` | UI fonts and Nerd Fonts |
| `60-audio-media.txt` | Audio and media components |
| `70-theming.txt` | GTK/Qt theme tools |
| `80-gpu-*.txt` | AMD, Intel or NVIDIA drivers |
| `90-networking.txt` | Networking and Bluetooth |
| `95-extra.txt` | Additional utilities |

Wallpaper color extraction needs Python, NumPy and Pillow. Brave (`brave-bin` on
my machine) is installed separately. The optional Codex launcher also requires
your own `~/.local/bin/codex` installation.

## 3. Apply the configs

```bash
chezmoi apply --interactive --exclude=scripts
```

This asks before each change and skips the automatic setup hooks. Review the
user-service links included in the diff; services may start with the desktop.
Once packages are installed, review and run the desktop service helper:

```bash
~/.config/hypr/scripts/bootstrap.sh
```

That helper links the desktop's user units and enables the required services.
The optional OpenRGB server is excluded. The native RGB helpers use the device
permissions supplied by OpenRGB's package; reconnect devices or reboot after
installing it. Run the helpers as your normal user.

Start a new Hyprland session, then choose a wallpaper with `Super + Space`.
See the [desktop guide](desktop.md) for host profiles and color synchronization.

## Optional full bootstrap

The separate [scripts/bootstrap.sh](../scripts/bootstrap.sh) performs a full
system upgrade, installs package lists and GPU drivers, changes the login shell,
installs SDDM, enables services and force-applies the configs. Review it before
running it. The staged steps above let you choose each part yourself.

[system/](../system/) contains the greeter and supplemental snapshots. Chezmoi
excludes that folder from home deployment. Bootstrap installs the SDDM files;
bootloader reference files and browser/dconf snapshots require manual handling.
See [supplemental settings](repository.md#supplemental-settings).

## What stays local

Accounts, credentials, browser profiles, caches, generated cursor variants and
wallpaper runtime state stay on your machine. Wallpapers over 100 MiB are
excluded. A new installation starts with a default accent until you select a
wallpaper. RGB support depends on your hardware; the native ASUS/G305 path is
specific to my laptop and mouse.

[Back to the guides](README.md)
