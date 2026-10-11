# Restore HyprDodz on a new installation

Chezmoi saves the desktop's user files, wallpapers, themes, scripts, and service
links. Start with a working Arch/CachyOS installation and the same supported
hardware to reproduce the native G305 and ASUS keyboard lighting path. The OS,
kernel, drivers, application installations, and account credentials
are separate prerequisites.

## 1. Download and review

Install Git and chezmoi yourself through pacman if necessary, then authenticate
to GitHub using your own account. Do not store authentication files in this repo.

```bash
# Run yourself only if needed:
# sudo pacman -S --needed git chezmoi

chezmoi init Dodzux/HyprDodz
chezmoi diff --exclude=scripts
```

Initialization records the current machine's hostname, GPU choice, and display
name. A hostname without a matching profile uses `hosts/default.lua` with
preferred monitor modes and automatic GPU selection. The removed `hyprdodz.lua`
profile is intentionally not restored. Review profiles before selecting one.

## 2. Install the desktop packages yourself

Review the categorized files in `packages/` and install the packages appropriate
to the new OS and desktop through pacman. Do not blindly install all GPU manifests;
keep the drivers already supplied by the OS until you have chosen your own setup.
Some packages can depend on the CachyOS repositories or require a separately
reviewed package source on plain Arch.

The accent pipeline requires Python, NumPy, Pillow, and the wallpaper tooling.
The saved manifests include `python-numpy`, `python-pillow`, `awww`, `hyprland`,
`quickshell`, and `openrgb`. The RGB shell wrappers also need Bash, `flock`
(util-linux), `timeout` (coreutils), and `pgrep` (procps-ng), normally available
in an Arch base installation. Verify the installed dependencies with:

```bash
pacman -Q python python-numpy python-pillow openrgb util-linux coreutils procps-ng
```

OpenRGB supplies HID-access udev rules used by the native helper. After installing
it, reconnect the receiver or reboot and log into an active desktop session so
the packaged access rules can take effect. Do not run the RGB helper with sudo.
If access still fails, inspect permissions and the packaged rule before making
any system change; no custom system rule is included in this restore.

## 3. Apply the reviewed user configs

Back up any existing configuration you want to preserve before proceeding.
Review the diff, including systemd user-service links: these can start services
when the desktop session starts. Confirm each desired file change:

```bash
chezmoi apply --interactive --exclude=scripts
```

This defers the repository's `run_*` setup hooks. The legacy root
`scripts/bootstrap.sh` makes broader system changes and uses a forced apply;
it is not required for this staged restore. Do not run it before reviewing those
operations. System SDDM/greeter settings and other `system/` references require a
separate deliberate choice; chezmoi does not deploy them to `/etc` or `/usr`.

Review `~/.config/hypr/scripts/bootstrap.sh` if you want to install/reconcile the
Hyprland user units. Run it yourself only after approving the links and listed
service enablement. It no longer enables `openrgb-server.service`, and it does
not disable an already enabled server. Avoid an OpenRGB process competing with
the native mouse helper. On other board models, review the generic SDK fallback
requirements separately.

## 4. Start the desktop and verify accents

After the desktop packages and user units are ready, start a new Hyprland session
and select a saved wallpaper from the wallpaper selector (`SUPER + Space`).
The session restores the wallpaper and runs the accent pipeline; bounded mouse
startup retries handle delayed wireless wake-up. Mouse settings are volatile and
must be written again after a reconnect/reset.

The selected wallpaper, mouse acknowledgement files, HID capability cache,
generated cursor variants, and `~/.local/state/hypr` are runtime state, so a fresh
installation may initially use the default accent. Selecting a wallpaper
regenerates the needed state from the saved configs and assets. Browser accounts,
SSH keys, private credentials, and wallpapers excluded for size remain separate.

Run the hardware-free routing tests in the source repository:

```bash
cd ~/.local/share/chezmoi
python3 scripts/test-mouse-rgb.py
chezmoi diff --exclude=scripts
```

The tests check routing, input validation, error handling, and stale requests.
They do not prove all cold-boot or suspend/resume behaviour on a new installation.
