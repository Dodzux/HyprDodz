#!/usr/bin/env python3
"""On-demand Hyprsunset controls. No daemon, saved mode flags, or polling loop."""
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time

TEMPERATURE = 5500
DIM_GAMMA = 65


def command(args, check=True):
    p = subprocess.run(args, capture_output=True, text=True, timeout=6)
    if check and p.returncode:
        raise RuntimeError(p.stderr.strip() or p.stdout.strip() or 'Display command failed')
    return p


def ipc(*args):
    text = command(['hyprctl', 'hyprsunset', *args]).stdout.strip()
    return text


def status():
    if command(['systemctl', '--user', 'is-active', '--quiet', 'hyprsunset.service'], False).returncode:
        return {'nightLight': False, 'extraDim': False, 'temperature': TEMPERATURE, 'gamma': 100}
    identity = ipc('identity', 'get')
    if identity not in ('true', 'false'):
        raise RuntimeError('Display filter has not finished starting')
    temperature = int(ipc('temperature'))
    gamma = float(ipc('gamma'))
    return {'nightLight': identity == 'false', 'extraDim': gamma < 99.5,
            'temperature': temperature, 'gamma': gamma}


def apply(night, dim, temperature=TEMPERATURE, gamma=None):
    for args in [('temperature', str(temperature)) if night else ('identity',),
                 ('gamma', str(gamma if gamma is not None else DIM_GAMMA if dim else 100))]:
        if ipc(*args) != 'ok':
            raise RuntimeError('Display filter rejected the requested mode')


def change(action):
    before = status()
    if action == 'status':
        return before
    if action not in ('night-light', 'extra-dim'):
        raise ValueError('Use status, night-light or extra-dim')
    night, dim = before['nightLight'], before['extraDim']
    if action == 'night-light':
        night = not night
    else:
        dim = not dim
    if not night and not dim:
        command(['systemctl', '--user', 'stop', 'hyprsunset.service'])
        return status()
    started = not before['nightLight'] and not before['extraDim']
    command(['systemctl', '--user', 'start', 'hyprsunset.service'])
    try:
        deadline = time.monotonic() + 2
        while True:
            try:
                if ipc('identity', 'get') in ('true', 'false'):
                    break
            except RuntimeError:
                pass
            if time.monotonic() >= deadline:
                raise RuntimeError('Display filter did not become ready')
            time.sleep(.05)
        apply(night, dim)
        result = status()
        if result['nightLight'] != night or result['extraDim'] != dim:
            raise RuntimeError('Display filter state did not match the request')
        return result
    except Exception:
        # Do not leave an unrequested filter behind after a partial failure.
        if started:
            command(['systemctl', '--user', 'stop', 'hyprsunset.service'], False)
        else:
            try:
                apply(before['nightLight'], before['extraDim'], before['temperature'], before['gamma'])
            except Exception:
                pass
        raise


if __name__ == '__main__':
    try:
        runtime = Path(os.environ.get('XDG_RUNTIME_DIR', '/run/user/' + str(os.getuid())))
        with (runtime / 'desktop-display-modes.lock').open('w') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            print(json.dumps(change(sys.argv[1] if len(sys.argv) == 2 else 'status')))
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
