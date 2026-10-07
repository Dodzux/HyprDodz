# Native mouse lighting upload review

Reviewed on 2026-10-07 for the existing private HyprDodz repository.

## Imported local changes

- `modules/autostart.lua`: bounded startup retries for a sleeping wireless mouse.
- `scripts/openrgb_mouse_color.sh`: preserve the working native HID++ helper
  routing instead of the earlier SDK-client wrapper.
- `scripts/bootstrap.sh` under the Hyprland config: exclude the OpenRGB server
  from the user units enabled by the setup script.
- `hosts/Potat0Mac.lua`: safe automatic monitor/GPU fallback settings.
- Forget the obsolete saved `hosts/hyprdodz.lua` as explicitly requested; its
  missing live file is not recreated, and a review backup is kept outside Git.

The native Logitech and ASUS helpers, parent RGB router, wallpaper and accent
scripts, theme assets, package manifests, and user-unit files were already saved
in the repository. The active generic fallback `openrgb_color.sh.before-g614ph`
is retained because the parent router executes it on other board models.

## Checks

The test runner now selects native or SDK cases based on the saved wrapper.
Fourteen native-path checks cover valid/invalid input, receiver-owner contention,
missing helper/state, stale and superseded requests, native failures, preservation
of an earlier success marker, a bounded timeout, and parent-script dispatch.
Hardware calls are mocked: the tests do not send HID reports, launch OpenRGB,
change services, or change live dotfiles.

Bash syntax and Lua parsing are checked for the imported shell and autostart
files. Chezmoi's scoped diff is reviewed after import, along with the Git patch,
whitespace checks, and credential/privacy scanning of the upload.

These checks establish routing and error handling, not a guarantee for every
hardware, kernel, cold boot, suspend/resume, or wireless wake condition. The
other agent's working hardware implementation is preserved without rewriting it.

## Fresh-install requirements

See [restore instructions](restore-on-new-install.md). Native mouse access uses
Python's standard library; Bash, `flock`, `timeout`, and `pgrep` must be present.
The manifests include `python-numpy`/`python-pillow`, which provide the desktop
Python dependencies, and OpenRGB. OpenRGB is also needed for its packaged udev
permissions even when the G305 update does not use its SDK server.

On the reviewed installation, `60-openrgb.rules` is owned by the `openrgb`
package. It grants active-session `uaccess` for Logitech HID devices and the
ASUS `0b05:19b6` keyboard. No custom rules are present under `/etc/udev/rules.d`.
This task does not install packages, change rules, reload udev, or touch hardware.
A new installation needs device re-enumeration and an active desktop session
for the packaged permissions to take effect.

The native parent branch currently selects the ASUS `G614PH` board. The Logitech
helper verifies the G305 model (`046d:4074`), receiver (`046d:c53f`), and supported
HID++ lighting feature. These are hardware selectors, not credentials. Other
boards use the existing OpenRGB fallback and can require a separately reviewed
SDK-server setup. Runtime receiver identities/capability caches are not saved.

## Privacy and exclusions

Only reviewed configuration files are imported individually. Local backups,
OpenRGB logs, Python caches, generated cursors, mouse runtime state, credentials,
browser profiles, application sessions, and GitHub authentication stay local.
The new host-profile filename is hostname-specific, but its settings contain no
monitor identifiers, GPU addresses, private paths, or credentials. The imported
changes use `$HOME` and runtime variables rather than an absolute personal home.

Chezmoi reports existing directory-mode drift for GitHub CLI and Inkscape;
those directories are not re-added for this upload. No system file or live
configuration is changed by the import, tests, commit, or push.

A proposed-tree text scan inspected 49,513 UTF-8 files and found no matches for
private-key headers, known token/access-key formats, credential URLs, or quoted
credential assignments. Binary, oversized, and symlink entries were not inspected
as text (1,786 entries); pattern scans cannot establish that every arbitrary
secret is absent. The imported text files have no credential findings.

Existing privacy/portability details outside this upload: `dot_gitconfig` contains
a Git author email; `dot_config/btop/btop.conf` contains an absolute home path;
one bundled icon contains an authoring-time home path. Bundled theme/icon author
emails and Firefox's theme ID are metadata rather than app authentication. These
files are not re-added or altered by this change. No discovered value is printed
in the review.

## Final verification results

- All 14 native-path tests passed against the imported source repository.
- Bash syntax, Lua parsing, and Git whitespace checks passed.
- The scoped chezmoi diff is empty for all four imported files.
- The full file-only chezmoi diff shows the pre-existing `0751` versus `0755`
  directory metadata differences for GitHub CLI and Inkscape; no content drift
  remains in the imported configuration.
- At review time, the current mouse success marker matches the desired wallpaper
  colour and no OpenRGB process is present. This is an acknowledgement-state
  observation, not independent visual verification of the indicator.
- Live configuration hashes are unchanged from before the import.
