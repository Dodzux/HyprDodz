#!/usr/bin/env python3
"""Cycle the laptop's existing power profiles and notify after confirmation."""
from pathlib import Path
import fcntl
import os
import subprocess
import sys
import time

MODES = [
    ("power-saver", "Silent", "Lower power · quieter fans"),
    ("balanced", "Performance", "Balanced speed and fan noise"),
    ("performance", "Turbo", "Maximum performance"),
]


def command(*args):
    result = subprocess.run(args, capture_output=True, text=True, timeout=5)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or "Command failed: " + args[0])
    return result.stdout.strip()


def notify(runtime, title, body, icon):
    saved = runtime / "performance-mode.notification"
    args = ["notify-send", "--app-name=Performance mode", "--expire-time=3000",
            "--icon=" + icon, "--print-id"]
    try:
        age = time.time() - saved.stat().st_mtime
        previous = saved.read_text().strip()
        # The shell keeps expired cards in history. Reuse only a still-visible
        # popup, with a margin before its 3-second expiry starts fading out.
        if previous.isdecimal() and 0 <= age < 2.5:
            args.append("--replace-id=" + previous)
    except OSError:
        pass
    identifier = command(*args, title, body)
    if identifier.isdecimal():
        saved.write_text(identifier + "\n")


def main():
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/run/user/" + str(os.getuid())))
    with (runtime / "performance-mode.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return 0
        try:
            current = command("powerprofilesctl", "get")
            keys = [mode[0] for mode in MODES]
            index = (keys.index(current) + 1) % len(MODES) if current in keys else 0
            key, title, detail = MODES[index]
            command("powerprofilesctl", "set", key)
            if command("powerprofilesctl", "get") != key:
                raise RuntimeError("The requested performance mode was not confirmed")
        except (OSError, RuntimeError, subprocess.SubprocessError) as error:
            try:
                notify(runtime, "Could not change performance mode", str(error)[:220], "dialog-error-symbolic")
            except (OSError, RuntimeError, subprocess.SubprocessError):
                pass
            print(error, file=sys.stderr)
            return 1
        try:
            notify(runtime, title + " mode", detail, "power-profile-" + key + "-symbolic")
        except (OSError, RuntimeError, subprocess.SubprocessError) as error:
            print("Changed mode, but notification failed: " + str(error), file=sys.stderr)
            return 1
        print(key)
        return 0


if __name__ == "__main__":
    sys.exit(main())
