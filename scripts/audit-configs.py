#!/usr/bin/env python3
"""Check configuration coverage, including files chezmoi does not manage yet."""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import fnmatch
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import json
import stat

from user_settings import browser_preferences


ROOTS = (
    '.config', '.bash_logout', '.bash_profile', '.bashrc', '.zshrc', '.gitconfig',
    '.gtkrc-2.0', '.nvidia-settings-rc', '.icons', '.themes', '.local/bin',
    '.local/share/applications', '.local/share/color-schemes',
    '.local/share/icons', '.local/share/themes', '.local/share/nwg-look',
    'Pictures/Wallpapers',
)

# Tracked files take precedence over these rules. No raw profile is copied to Git.
EXCLUSIONS = (
    ('.config/BraveSoftware/*', 'Browser profile, accounts, history, caches; selected ordinary preferences exported separately'),
    ('.config/mozilla/*', 'Firefox profile, accounts, history, caches; selected ordinary preferences exported separately'),
    ('.config/discord/*', 'Discord account/session data, caches, installed application files'),
    ('.config/obsidian/*', 'Obsidian account/session data, caches, installed application files'),
    ('.config/chezmoi/*', 'Machine-local chezmoi configuration and persistent database'),
    ('.config/gh/hosts.yml', 'GitHub authentication/account data'),
    ('.config/pulse/*', 'PulseAudio authentication cookie'),
    ('.config/session/*', 'Restorable application session state'),
    ('.config/fish/fish_variables', 'Fish-generated universal-variable state'),
    ('.config/micro/buffers', 'Editor buffer/session state'),
    ('.config/micro/buffers/*', 'Editor buffer/session state'),
    ('.config/VirtualBox/*', 'VirtualBox runtime registrations, logs, or backups'),
    ('.config/obs-studio/plugin_config/obs-websocket/*', 'OBS WebSocket configuration contains a password'),
    ('.config/obs-studio/plugin_config/rtmp-services/*', 'Downloaded OBS service catalog'),
    ('.config/obs-studio/profiler_data/*', 'OBS performance/profiler output'),
    ('.config/hypr/hyprwiki/*', 'Downloaded documentation'),
    ('.config/quickshell/quickshell-documentation/*', 'Downloaded documentation'),
    ('.config/yazi/yazi-documentation/*', 'Downloaded documentation'),
    ('.config/quickshell/.qmlls.ini', 'Generated language-server configuration'),
    ('.local/bin/codex', 'Installed Codex executable; launcher configuration is tracked'),
    ('.local/share/applications/mimeinfo.cache', 'Generated desktop-entry cache'),
    ('.local/share/icons/Bibata-Accent-*/*', 'Generated wallpaper cursor variant; base theme is tracked'),
    ('*/.git/*', 'Nested version-control metadata'),
    ('*/.agents/*', 'Local agent workspace'),
    ('*/.claude/*', 'Local agent workspace'),
    ('*/.codex/*', 'Local agent workspace'),
    ('*/__pycache__/*', 'Python bytecode cache'),
    ('*/logs/*', 'Application logs'),
    ('*.log', 'Application log'),
    ('*.log.*', 'Rotated application log'),
    ('*.before-*', 'Previous configuration experiment/backup'),
    ('*.bak', 'Backup file'),
    ('*.backup', 'Backup file'),
    ('*.tmp', 'Temporary file'),
    ('*.swp', 'Editor swap file'),
    ('*.swo', 'Editor swap file'),
    ('*.pyc', 'Python bytecode cache'),
    ('*.pyo', 'Python bytecode cache'),
    ('*~', 'Editor backup file'),
    ('*.DS_Store', 'OS metadata'),
)


def live_entries(home):
    """Include empty directories and symlink directories without following links."""
    found = set()
    for relative in ROOTS:
        root = home / relative
        if root.is_symlink() or root.is_file():
            found.add(root)
        elif root.is_dir():
            for base, directories, files in os.walk(root):
                if not directories and not files:
                    found.add(Path(base))
                for directory in list(directories):
                    path = Path(base) / directory
                    if path.is_symlink():
                        found.add(path)
                        directories.remove(directory)
                found.update(Path(base) / name for name in files)
    return sorted(found)


def excluded_reason(relative, path):
    if relative == '.config/dconf/user':
        return 'captured', 'dconf settings exported to system/user/dconf.ini.tmpl'
    if relative.startswith('Pictures/Wallpapers/') and path.is_file() and path.stat().st_size > 100 * 1024 ** 2:
        return 'excluded', 'Wallpaper exceeds 100 MiB; kept local by request'
    for pattern, reason in EXCLUSIONS:
        if fnmatch.fnmatchcase(relative, pattern):
            return 'excluded', reason
    return 'missing', 'Not managed and no exclusion applies'


def group_for(relative):
    parts = Path(relative).parts
    if parts[0] == '.config':
        return '/'.join(parts[:2])
    if relative.startswith('.local/share/'):
        return '/'.join(parts[:3])
    if relative.startswith('Pictures/'):
        return '/'.join(parts[:2])
    if relative.startswith('.local/'):
        return '/'.join(parts[:2])
    return parts[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, help='Write the full Markdown coverage report here')
    args = parser.parse_args()
    home = Path.home()
    repo = Path(__file__).resolve().parent.parent
    managed = set(subprocess.check_output(
        ['chezmoi', '--source', str(repo), 'managed', '--path-style=absolute'], text=True,
    ).splitlines())
    rows = defaultdict(Counter)
    reasons = defaultdict(list)
    missing, changed, normalized = [], [], []

    # An archive renders templates without applying configs or running scripts.
    with tempfile.TemporaryDirectory(prefix='chezmoi-coverage-') as temporary:
        archive_path = Path(temporary) / 'rendered.tar'
        subprocess.run(['chezmoi', '--source', str(repo), 'archive', '--format=tar', '--output', str(archive_path)], check=True)
        with tarfile.open(archive_path) as archive:
            members = {entry.name.rstrip('/'): entry for entry in archive.getmembers()}
            for path in live_entries(home):
                relative = str(path.relative_to(home))
                group = group_for(relative)
                if str(path) not in managed:
                    category, reason = excluded_reason(relative, path)
                    rows[group][category] += 1
                    reasons[(group, reason)].append(relative)
                    if category == 'missing':
                        missing.append(relative)
                    continue
                entry = members.get(relative)
                if path.is_dir() and not path.is_symlink():
                    # Archive output omits empty dirs; their presence in managed is enough.
                    matches = True
                elif path.is_symlink():
                    matches = entry is not None and entry.issym() and os.readlink(path) == entry.linkname
                    if (not matches and entry is not None and entry.issym()
                            and not path.exists()
                            and os.readlink(path).strip() == entry.linkname
                            and (path.parent / entry.linkname).exists()):
                        # chezmoi strips surrounding whitespace from symlink targets.
                        # Record this exception instead of claiming byte-for-byte equality.
                        normalized.append(relative)
                        matches = True
                elif entry is not None and entry.isfile():
                    with path.open('rb') as live, archive.extractfile(entry) as saved:
                        matches = True
                        while True:
                            a, b = live.read(1024 * 1024), saved.read(1024 * 1024)
                            if a != b:
                                matches = False
                                break
                            if not a:
                                break
                else:
                    matches = False
                rows[group]['tracked'] += 1
                if not matches:
                    changed.append(relative)
                    rows[group]['different'] += 1

    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
    totals = sum(rows.values(), Counter())
    captures = []
    snapshot = repo / 'system/user/browser-preferences.json'
    if not snapshot.exists() or json.loads(snapshot.read_text()) != browser_preferences(home):
        captures.append('Selected browser preferences differ; refresh with python3 scripts/user_settings.py')
    if not (repo / 'system/user/dconf.ini.tmpl').is_file():
        captures.append('The separate dconf settings snapshot is missing')
    permission_file = repo / 'system/user/directory-permissions.json'
    permissions = json.loads(permission_file.read_text()) if permission_file.exists() else {}
    for relative, mode in permissions.items():
        path = home / relative
        if not path.is_dir() or format(stat.S_IMODE(path.stat().st_mode), '04o') != mode:
            captures.append(f'Directory mode differs from the separate snapshot: {relative}')
    lines = [
        '# Configuration coverage', '', f'Checked: {timestamp}.', '',
        'This compares live configuration files and symlinks with chezmoi’s rendered state,',
        'and also searches for files that chezmoi does not manage. Source filenames such as',
        '`dot_config`, `private_`, `executable_`, and `.tmpl` encode deployment behavior;',
        'they are not expected to look identical to the live folder names.', '',
        f'**{totals["tracked"]} tracked entries checked; {len(changed)} content/link differences;',
        f'{len(missing)} unexplained missing entries.**', '',
        f'{len(normalized)} malformed live symlink target(s) are normalized by chezmoi; see below.', '',
        '| Live folder/file | Tracked | Different | Captured separately | Excluded | Missing |',
        '| --- | ---: | ---: | ---: | ---: | ---: |',
    ]
    for group, counts in sorted(rows.items()):
        lines.append(f'| `{group}` | {counts["tracked"]} | {counts["different"]} | {counts["captured"]} | {counts["excluded"]} | {counts["missing"]} |')
    lines += ['', '## Exclusions and separate captures', '',
              'Private accounts/sessions, caches, downloaded applications, logs, generated',
              'cursor variants, and backups stay local. Selected ordinary Brave/Firefox',
              'preferences are in `system/user/browser-preferences.json`; this is a partial',
              'settings snapshot, not a browser-profile backup. dconf is captured as text',
              'in `system/user/dconf.ini.tmpl` rather than copying its binary database.', '',
              '| Location | Entries | Reason |', '| --- | ---: | --- |']
    for (group, reason), entries in sorted(reasons.items()):
        lines.append(f'| `{group}` | {len(entries)} | {reason} |')
    lines += ['', '## Differences', '']
    lines += [f'- `{path}`' for path in changed] or ['None.']
    lines += ['', '## Unexplained missing entries', '']
    lines += [f'- `{path}`' for path in missing] or ['None.']
    lines += ['', '## Normalized symlink targets', '']
    lines += [f'- `{path}`: live target contains surrounding whitespace and is broken; chezmoi strips that whitespace.' for path in normalized] or ['None.']
    lines += ['', '## Directory permissions', '',
              'These directories have custom permission modes that chezmoi cannot encode',
              'in source attributes. Their original modes are saved separately in',
              '`system/user/directory-permissions.json` and match the live folders.',
              '`chezmoi status` may still show permission differences for these paths.', '',
              '| Directory | Original mode |', '| --- | --- |']
    lines += [f'| `{path}` | `{mode}` |' for path, mode in sorted(permissions.items())]
    lines += ['', 'After applying on another machine, restore them with:', '', '```sh',
              'python3 scripts/restore-config-permissions.py', '```']
    lines += ['', '## Separate snapshot checks', '']
    lines += [f'- {message}' for message in captures] or [
        'Selected browser preferences match the live settings. The dconf text snapshot',
        'exists; this audit does not compare its content with the running dconf database.',
    ]
    lines += ['', '## Run again', '', '```sh', 'python3 scripts/audit-configs.py --report CONFIG-COVERAGE.md', '```', '',
              'A new file that is neither tracked nor explicitly excluded makes the audit fail.',
              'The audit does not scan all personal documents, installed programs, or system',
              'files under `/etc` and `/usr`; those are outside these home-config roots.', '']
    report = '\n'.join(lines)
    if args.report:
        args.report.write_text(report)
        print(f'Wrote {args.report}: {totals["tracked"]} tracked, {len(changed)} different, {len(missing)} missing, {len(captures)} snapshot issues')
    else:
        print(report)
    return 1 if missing or changed or captures else 0


if __name__ == '__main__':
    raise SystemExit(main())
