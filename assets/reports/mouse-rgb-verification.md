# Mouse RGB verification — 2026-10-07

The only live RGB configuration that differed from the existing chezmoi source
was `~/.config/hypr/scripts/openrgb_mouse_color.sh`. Related wallpaper, cursor,
keyboard, and accent scripts already matched their managed source files.

## Verified behaviour

- Nineteen hardware-free checks cover the observed duplicate G305 entries,
  exclusion of other devices, Static/Direct modes, missing or unsupported
  devices, nonzero exits, errors reported with exit code zero, timeouts,
  superseded requests, input validation, symlink rejection, and dispatch
  through the real parent RGB script with hardware commands mocked.
- Bash syntax checks passed for the mouse, parent RGB, and wallpaper scripts.
  Python syntax checks passed for the accent, cursor, keyboard, mouse HID,
  and GTK theme helpers. The Fish RGB picker passed its syntax check.
- Live verification found OpenRGB 1.0 with an active user SDK service and two
  G305 entries. Extracting the current wallpaper colour matched the saved
  accent. Replaying only the RGB worker with that colour completed in about
  1.1 seconds and refreshed the mouse and keyboard colour markers.
- The verification replay did not change live config scripts. The reviewed
  mouse wrapper was then installed after preserving the preceding version
  in a backup outside this repository, and imported individually with chezmoi.
- The imported source matches the installed wrapper. Its scoped chezmoi diff
  is empty. Nothing was committed or pushed, and chezmoi apply was not run.

## Failure handling corrected during review

The earlier recovery wrapper could accept an OpenRGB error as success when
the CLI returned zero. The regression suite reproduced this. The imported
wrapper checks both command status and error messages, keeps raw SDK output
out of logs, and only records a successful update for the current generation.
The success-marker check and write use the wallpaper publisher's request lock.

## Privacy and dependencies

No credentials, keys, cookies, email addresses, hostnames, or absolute paths
containing a username were found in the proposed code changes. SDK device
details and serial numbers are neither logged nor copied into the repository.
Backups, runtime state, device caches, diagnostic output, and recovery files
in Projects were excluded from the import. Repository reports and test tools
are already excluded from chezmoi application by `assets/**` and `scripts/**`.

The wrapper specifically selects G305 entries and expects an already-running
SDK server on localhost port 6742. It also needs Bash, OpenRGB, `flock`, and
`timeout`. The parent keyboard path remains specific to the ASUS G614PH;
tests stub that hardware identity rather than probe a real device.

## Limits

Passing these checks is evidence for the tested paths, not a guarantee against
every possible bug. Colour markers and CLI completion confirm that requests
were sent; they are not physical LED readback. Cold boot, suspend/resume,
receiver reconnection, and firmware changes were not exercised. An unavailable
SDK server causes a reported failure; the wrapper never starts services or
falls back to competing raw HID writes. The full desktop apply operation was
not run during verification because it rewrites other live configurations.

Run `python3 scripts/test-mouse-rgb.py` from the source repository to repeat the
hardware-free checks. Change wallpapers normally to visually check the live
indicator. Review `chezmoi diff` before any future apply.
