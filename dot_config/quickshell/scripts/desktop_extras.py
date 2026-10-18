#!/usr/bin/env python3
"""On-demand desktop preferences, wallpaper history, workspace actions and diagnostics."""
import argparse
import contextlib
import fcntl
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import tempfile

STATE = Path(os.environ.get('XDG_STATE_HOME') or Path.home() / '.local/state') / 'quickshell'
CONTROLS = ['stats', 'network', 'bluetooth', 'audio', 'mic', 'brightness', 'battery']
STATUS = ['language', 'notifications', 'shortcuts', 'tray', 'settings', 'power']


def read(name, default):
    try:
        return json.loads((STATE / name).read_text())
    except FileNotFoundError:
        return default


def write(name, data):
    STATE.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode='w', dir=STATE, delete=False) as stream:
        temp = Path(stream.name)
        try:
            json.dump(data, stream, ensure_ascii=False)
            stream.flush()
            os.fsync(stream.fileno())
        except BaseException:
            temp.unlink(missing_ok=True)
            raise
    try:
        os.replace(temp, STATE / name)
    finally:
        temp.unlink(missing_ok=True)


def preferences(data):
    if not isinstance(data, dict):
        raise ValueError('Invalid preferences')
    controls, status = data.get('controls', CONTROLS), data.get('status', STATUS)
    if not isinstance(controls, list) or not isinstance(status, list):
        raise ValueError('Invalid layout')
    if any(not isinstance(k, str) for k in controls + status) or sorted(controls + status) != sorted(CONTROLS + STATUS):
        raise ValueError('Each bar control must occur exactly once')
    favorites = data.get('favorites', [])
    labels = data.get('labels', {})
    if not isinstance(favorites, list) or len(favorites) > 500 or any(not isinstance(p, str) or len(p) > 4096 for p in favorites):
        raise ValueError('Invalid favorites')
    if not isinstance(labels, dict) or len(labels) > 100:
        raise ValueError('Invalid workspace labels')
    if any(not re.fullmatch(r'[1-9][0-9]{0,4}', k) or not isinstance(v, str) or len(v) > 24 or any(ord(c) < 32 for c in v) for k, v in labels.items()):
        raise ValueError('Workspace names must be at most 24 printable characters')
    return {'controls': controls, 'status': status,
            'favorites': list(dict.fromkeys(favorites)), 'labels': labels}


def record_wallpaper(path, previous):
    if not Path(path).is_file():
        raise ValueError('Wallpaper is unavailable')
    STATE.mkdir(parents=True, exist_ok=True)
    with (STATE / 'wallpaper-history.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        old = read('wallpaper-history.json', {})
        if old.get('current') == path:
            return old
        prior = old.get('current') if old.get('current') and Path(old['current']).is_file() else previous
        if prior == path:
            prior = old.get('previous', '')
        data = {'current': path, 'previous': prior or ''}
        write('wallpaper-history.json', data)
        return data


def undo_wallpaper():
    data = read('wallpaper-history.json', {})
    previous = data.get('previous', '')
    if not previous or not Path(previous).is_file():
        raise ValueError('No previous wallpaper is available yet')
    script = Path.home() / '.config/hypr/scripts/awww_transition.sh'
    subprocess.Popen(['bash', str(script), previous], stdin=subprocess.DEVNULL,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True, close_fds=True)
    return {'ok': True, 'message': 'Restoring previous wallpaper and its theme'}


def workspace_action(request):
    from desktop_data import hypr_json, dispatch, workspace_id
    target = workspace_id(request.get('workspace'))
    action = request.get('action')
    clients = hypr_json('clients')
    candidates = [c for c in clients if c.get('mapped') and not c.get('hidden') and not c.get('pinned')
                  and c.get('workspace', {}).get('id', 0) != 0]
    if action == 'inspect':
        active = hypr_json('activewindow')
        ordered = sorted(candidates, key=lambda c: (c['address'] != active.get('address'), c.get('focusHistoryID', 9999)))
        windows = [{'address': c['address'], 'class': c.get('initialClass') or c.get('class', ''),
                    'pid': c.get('pid', 0), 'workspace': c['workspace']['id'],
                    'label': (c.get('initialClass') or c.get('class', 'Window')) + ' · ' + str(c['workspace'].get('name', c['workspace']['id']))}
                   for c in ordered]
        return {'ok': True, 'windows': windows}
    if action not in ('move', 'gather'):
        raise ValueError('Unknown workspace action')
    address = request.get('expectedAddress', '')
    if not isinstance(address, str) or not re.fullmatch(r'0x[0-9a-fA-F]+', address):
        raise ValueError('Choose a source window')
    source = next((c for c in candidates if c['address'] == address), None)
    if not source:
        raise ValueError('That source window closed or became unavailable; refresh the list')
    if request.get('expectedPid') and source.get('pid') != request['expectedPid']:
        raise ValueError('That source window changed; refresh the list')
    if 'expectedSource' in request and source['workspace']['id'] != request['expectedSource']:
        raise ValueError('That window moved since the list was opened; refresh it')
    app_class = source.get('initialClass') or source.get('class', '')
    selected = [c for c in candidates if c['workspace']['id'] != target
                and ((c.get('initialClass') or c.get('class', '')) == app_class if action == 'gather' else c['address'] == address)]
    def original_workspace(client):
        ws = client['workspace']
        if ws['id'] > 0:
            return str(ws['id'])
        name = ws.get('name', '')
        if not re.fullmatch(r'special:[A-Za-z0-9_-]{1,64}', name):
            raise ValueError('This special workspace cannot be restored safely')
        return json.dumps(name)
    for client in selected:
        original_workspace(client)
    completed = []
    try:
        for client in selected:
            addr = client['address']
            if not re.fullmatch(r'0x[0-9a-fA-F]+', addr):
                raise ValueError('Invalid window address')
            dispatch(f'hl.dsp.window.move({{workspace={target}, follow=false, window="address:{addr}"}})')
            completed.append(client)
    except Exception:
        for client in reversed(completed):
            dispatch(f'hl.dsp.window.move({{workspace={original_workspace(client)}, follow=false, window="address:{client["address"]}"}})')
        raise
    actual = {c['address']: c['workspace']['id'] for c in hypr_json('clients')}
    if any(actual.get(c['address']) != target for c in completed):
        raise ValueError('Workspace contents changed during the operation; review the overview')
    return {'ok': True, 'message': f'Moved {len(completed)} window(s) to workspace {target}'}


def health():
    checks = []
    for command in ('hyprctl', 'awww', 'wl-copy', 'brightnessctl', 'wpctl', 'powerprofilesctl'):
        found = shutil.which(command)
        checks.append({'name': command, 'status': 'ok' if found else 'warning', 'detail': 'Available' if found else 'Command missing'})
    for unit in ('quickshell.service', 'hypridle.service'):
        result = subprocess.run(['systemctl', '--user', 'is-active', unit], capture_output=True, text=True, timeout=3)
        active = result.returncode == 0
        if not active:
            process = subprocess.run(['pgrep', '-u', str(os.getuid()), '-x', unit.removesuffix('.service')], capture_output=True, timeout=2)
            active = process.returncode == 0
        checks.append({'name': unit, 'status': 'ok' if active else 'warning', 'detail': 'Running' if active else 'Not active'})
    result = subprocess.run(['hyprctl', 'configerrors'], capture_output=True, text=True, timeout=3)
    checks.append({'name': 'Hyprland configuration', 'status': 'ok' if result.returncode == 0 and not result.stdout.strip() else 'warning', 'detail': 'No configuration errors' if not result.stdout.strip() else 'Configuration errors reported; inspect hyprctl configerrors'})
    accent_path = Path(os.environ.get('XDG_STATE_HOME') or Path.home() / '.local/state') / 'hypr/accent'
    accent = accent_path.read_text().strip() if accent_path.is_file() else ''
    checks.append({'name': 'Wallpaper accent', 'status': 'ok' if re.fullmatch(r'#?[0-9a-fA-F]{6}', accent) else 'warning', 'detail': accent if re.fullmatch(r'#?[0-9a-fA-F]{6}', accent) else 'Saved accent unavailable'})
    broken = []
    appdir = Path.home() / '.local/share/applications'
    for entry in appdir.glob('*.desktop'):
        if not entry.is_file():
            broken.append(entry.name)
            continue
        text = entry.read_text(errors='replace')
        if re.search(r'^Hidden=true\s*$', text, re.M):
            continue
        match = re.search(r'^TryExec=(.+)$', text, re.M) or re.search(r'^Exec=(.+)$', text, re.M)
        if not match:
            continue
        try:
            args = shlex.split(match[1])
            command = args[0] if args else ''
            if command and command != 'env' and not shutil.which(command):
                broken.append(entry.name)
        except ValueError:
            broken.append(entry.name)
    checks.append({'name': 'Local app launchers', 'status': 'warning' if broken else 'ok', 'detail': ', '.join(broken[:8]) if broken else 'No missing executable detected'})
    return checks


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=['preferences', 'save', 'record-wallpaper', 'wallpaper-state', 'undo-wallpaper', 'workspace', 'health'])
    parser.add_argument('--request', default='{}')
    parser.add_argument('--path', default='')
    parser.add_argument('--previous', default='')
    args = parser.parse_args()
    try:
        if args.mode == 'preferences':
            result = preferences(read('desktop.json', {}))
        elif args.mode == 'save':
            result = preferences(json.loads(args.request))
            write('desktop.json', result)
            result = {'ok': True}
        elif args.mode == 'record-wallpaper':
            result = record_wallpaper(args.path, args.previous)
        elif args.mode == 'wallpaper-state':
            result = read('wallpaper-history.json', {})
        elif args.mode == 'undo-wallpaper':
            result = undo_wallpaper()
        elif args.mode == 'workspace':
            request = json.loads(args.request)
            if not isinstance(request, dict):
                raise ValueError('Invalid workspace request')
            result = workspace_action(request)
        else:
            result = health()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(json.dumps({'ok': False, 'message': str(error)}))
        return 1
    print(json.dumps(result))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
