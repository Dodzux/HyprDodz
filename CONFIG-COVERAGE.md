# Configuration coverage

Checked: 2026-10-07 11:10 UTC.

This compares live configuration files and symlinks with chezmoi’s rendered state,
and also searches for files that chezmoi does not manage. Source filenames such as
`dot_config`, `private_`, `executable_`, and `.tmpl` encode deployment behavior;
they are not expected to look identical to the live folder names.

**51242 tracked entries checked; 0 content/link differences;
0 unexplained missing entries.**

0 malformed live symlink target(s) are normalized by chezmoi; see below.

| Live folder/file | Tracked | Different | Captured separately | Excluded | Missing |
| --- | ---: | ---: | ---: | ---: | ---: |
| `.bash_logout` | 1 | 0 | 0 | 0 | 0 |
| `.bash_profile` | 1 | 0 | 0 | 0 | 0 |
| `.bashrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/BraveSoftware` | 0 | 0 | 0 | 4120 | 0 |
| `.config/Kvantum` | 6 | 0 | 0 | 0 | 0 |
| `.config/OpenRGB` | 3 | 0 | 0 | 11 | 0 |
| `.config/QtProject` | 1 | 0 | 0 | 0 | 0 |
| `.config/QtProject.conf` | 1 | 0 | 0 | 0 | 0 |
| `.config/VirtualBox` | 1 | 0 | 0 | 25 | 0 |
| `.config/arkrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/autostart` | 1 | 0 | 0 | 0 | 0 |
| `.config/baloofileinformationrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/btop` | 3 | 0 | 0 | 0 | 0 |
| `.config/cachyos` | 1 | 0 | 0 | 1 | 0 |
| `.config/cachyos-hello.json` | 1 | 0 | 0 | 0 | 0 |
| `.config/chezmoi` | 0 | 0 | 0 | 2 | 0 |
| `.config/dconf` | 0 | 0 | 1 | 0 | 0 |
| `.config/discord` | 1 | 0 | 0 | 7104 | 0 |
| `.config/dolphinrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/fish` | 12 | 0 | 0 | 1 | 0 |
| `.config/gh` | 1 | 0 | 0 | 1 | 0 |
| `.config/ghostty` | 3 | 0 | 0 | 0 | 0 |
| `.config/gtk-3.0` | 3 | 0 | 0 | 0 | 0 |
| `.config/gtk-4.0` | 4 | 0 | 0 | 0 | 0 |
| `.config/hypr` | 38 | 0 | 0 | 4 | 0 |
| `.config/inkscape` | 12 | 0 | 0 | 1 | 0 |
| `.config/kdeglobals` | 1 | 0 | 0 | 0 | 0 |
| `.config/kiorc` | 1 | 0 | 0 | 0 | 0 |
| `.config/kitty` | 5 | 0 | 0 | 1 | 0 |
| `.config/micro` | 153 | 0 | 0 | 0 | 0 |
| `.config/mimeapps.list` | 1 | 0 | 0 | 0 | 0 |
| `.config/mozilla` | 0 | 0 | 0 | 188 | 0 |
| `.config/mpv` | 1 | 0 | 0 | 0 | 0 |
| `.config/nvim` | 14 | 0 | 0 | 0 | 0 |
| `.config/nwg-look` | 1 | 0 | 0 | 0 | 0 |
| `.config/obs-studio` | 7 | 0 | 0 | 8 | 0 |
| `.config/obsidian` | 1 | 0 | 0 | 74 | 0 |
| `.config/pavucontrol.ini` | 1 | 0 | 0 | 0 | 0 |
| `.config/pulse` | 0 | 0 | 0 | 1 | 0 |
| `.config/qalculate` | 1 | 0 | 0 | 0 | 0 |
| `.config/qt6ct` | 3 | 0 | 0 | 0 | 0 |
| `.config/quickshell` | 45 | 0 | 0 | 4 | 0 |
| `.config/scripts` | 1 | 0 | 0 | 0 | 0 |
| `.config/session` | 0 | 0 | 0 | 1 | 0 |
| `.config/shelly` | 2 | 0 | 0 | 0 | 0 |
| `.config/starship.toml` | 1 | 0 | 0 | 0 | 0 |
| `.config/starshipfork.toml` | 1 | 0 | 0 | 0 | 0 |
| `.config/systemd` | 17 | 0 | 0 | 0 | 0 |
| `.config/trashrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/user-dirs.dirs` | 1 | 0 | 0 | 0 | 0 |
| `.config/uwsm` | 1 | 0 | 0 | 0 | 0 |
| `.config/xsettingsd` | 1 | 0 | 0 | 0 | 0 |
| `.config/yazi` | 4 | 0 | 0 | 0 | 0 |
| `.gitconfig` | 1 | 0 | 0 | 0 | 0 |
| `.gtkrc-2.0` | 1 | 0 | 0 | 0 | 0 |
| `.icons` | 1 | 0 | 0 | 0 | 0 |
| `.local/bin` | 2 | 0 | 0 | 1 | 0 |
| `.local/share/applications` | 2 | 0 | 0 | 1 | 0 |
| `.local/share/color-schemes` | 4 | 0 | 0 | 0 | 0 |
| `.local/share/icons` | 46420 | 0 | 0 | 615 | 0 |
| `.local/share/nwg-look` | 1 | 0 | 0 | 0 | 0 |
| `.local/share/themes` | 3786 | 0 | 0 | 0 | 0 |
| `.nvidia-settings-rc` | 1 | 0 | 0 | 0 | 0 |
| `.themes` | 631 | 0 | 0 | 0 | 0 |
| `.zshrc` | 1 | 0 | 0 | 0 | 0 |
| `Pictures/Wallpapers` | 28 | 0 | 0 | 1 | 0 |

## Exclusions and separate captures

Private accounts/sessions, caches, downloaded applications, logs, generated
cursor variants, and backups stay local. Selected ordinary Brave/Firefox
preferences are in `system/user/browser-preferences.json`; this is a partial
settings snapshot, not a browser-profile backup. dconf is captured as text
in `system/user/dconf.ini.tmpl` rather than copying its binary database.

| Location | Entries | Reason |
| --- | ---: | --- |
| `.config/BraveSoftware` | 4120 | Browser profile, accounts, history, caches; selected ordinary preferences exported separately |
| `.config/OpenRGB` | 10 | Application logs |
| `.config/OpenRGB` | 1 | Previous configuration experiment/backup |
| `.config/VirtualBox` | 25 | VirtualBox runtime registrations, logs, or backups |
| `.config/cachyos` | 1 | Application log |
| `.config/chezmoi` | 2 | Machine-local chezmoi configuration and persistent database |
| `.config/dconf` | 1 | dconf settings exported to system/user/dconf.ini.tmpl |
| `.config/discord` | 7104 | Discord account/session data, caches, installed application files |
| `.config/fish` | 1 | Fish-generated universal-variable state |
| `.config/gh` | 1 | GitHub authentication/account data |
| `.config/hypr` | 4 | Python bytecode cache |
| `.config/inkscape` | 1 | Application log |
| `.config/kitty` | 1 | Previous configuration experiment/backup |
| `.config/mozilla` | 188 | Firefox profile, accounts, history, caches; selected ordinary preferences exported separately |
| `.config/obs-studio` | 1 | Application logs |
| `.config/obs-studio` | 1 | Backup file |
| `.config/obs-studio` | 4 | Downloaded OBS service catalog |
| `.config/obs-studio` | 1 | OBS WebSocket configuration contains a password |
| `.config/obs-studio` | 1 | OBS performance/profiler output |
| `.config/obsidian` | 74 | Obsidian account/session data, caches, installed application files |
| `.config/pulse` | 1 | PulseAudio authentication cookie |
| `.config/quickshell` | 4 | Previous configuration experiment/backup |
| `.config/session` | 1 | Restorable application session state |
| `.local/bin` | 1 | Installed Codex executable; launcher configuration is tracked |
| `.local/share/applications` | 1 | Generated desktop-entry cache |
| `.local/share/icons` | 615 | Generated wallpaper cursor variant; base theme is tracked |
| `Pictures/Wallpapers` | 1 | Wallpaper exceeds 100 MiB; kept local by request |

## Differences

None.

## Unexplained missing entries

None.

## Normalized symlink targets

None.

## Directory permissions

These directories have custom permission modes that chezmoi cannot encode
in source attributes. Their original modes are saved separately in
`system/user/directory-permissions.json`. The audit checks them against
the live folders; mismatches appear under Separate snapshot checks.
`chezmoi status` may still show permission differences for these paths.

| Directory | Original mode |
| --- | --- |
| `.config/gh` | `0751` |
| `.config/inkscape` | `0751` |
| `.config/inkscape/extensions` | `0751` |
| `.config/inkscape/fontcollections` | `0751` |
| `.config/inkscape/icons` | `0751` |
| `.config/inkscape/keys` | `0751` |
| `.config/inkscape/paint` | `0751` |
| `.config/inkscape/palettes` | `0751` |
| `.config/inkscape/symbols` | `0751` |
| `.config/inkscape/templates` | `0751` |
| `.config/inkscape/themes` | `0751` |
| `.config/inkscape/ui` | `0751` |

After applying on another machine, restore them with:

```sh
python3 scripts/restore-config-permissions.py
```

## Separate snapshot checks

Selected browser preferences match the live settings. The dconf text snapshot
exists; this audit does not compare its content with the running dconf database.

## Run again

```sh
python3 scripts/audit-configs.py --report CONFIG-COVERAGE.md
```

A new file that is neither tracked nor explicitly excluded makes the audit fail.
The audit does not scan all personal documents, installed programs, or system
files under `/etc` and `/usr`; those are outside these home-config roots.
