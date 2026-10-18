#!/usr/bin/env python3
"""Validate saved configs without applying them or accessing the desktop."""
import ast
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def run(command, *, env=None, data=None):
    result = subprocess.run(command, cwd=ROOT, input=data, env=env, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"{' '.join(map(str, command))}\n{result.stdout}{result.stderr}")
    return result.stdout


def required(name, alternatives=()):
    binary = shutil.which(name)
    if binary:
        return binary
    for path in alternatives:
        if Path(path).is_file():
            return path
    raise RuntimeError(f"Missing check dependency: {name}")


def local_links():
    count = 0
    for path in [ROOT / 'README.md', *(ROOT / 'docs').rglob('*.md')]:
        for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', path.read_text()):
            if '://' in target or target.startswith(('mailto:', '#')):
                continue
            destination = target.split('#', 1)[0]
            if not (path.parent / destination).exists():
                raise ValueError(f"Broken local link in {path.relative_to(ROOT)}: {target}")
            count += 1
    print(f"PASS documentation: {count} local links")


def main():
    shell = required('bash')
    fish = required('fish')
    lua = required('luac', ('/usr/bin/luac5.4',))
    chezmoi = required('chezmoi')
    lint = required('qmllint', ('/usr/lib/qt6/bin/qmllint', '/usr/lib64/qt6/bin/qmllint'))
    roots = [ROOT / 'dot_config', ROOT / 'dot_local/bin', ROOT / 'scripts']
    files = sorted(p for root in roots for p in root.rglob('*') if p.is_file())
    counts = {'Python': 0, 'Lua': 0, 'shell': 0, 'Fish': 0, 'TOML': 0, 'JSON': 0}
    for path in files:
        relative = str(path.relative_to(ROOT))
        if '/__pycache__/' in relative:
            continue
        kind = path.suffix
        if kind in ('.py', '.lua', '.sh', '.fish', '.toml', '.json'):
            text = path.read_text()
        elif path.parent == ROOT / 'dot_local/bin':
            text = path.read_text()
            first = text.splitlines()[0] if text else ''
            kind = '.py' if 'python' in first else '.sh' if re.search(r'\b(bash|sh)\b', first) else ''
        else:
            continue
        if kind == '.py':
            ast.parse(text, filename=relative)
            counts['Python'] += 1
        elif kind == '.lua':
            run([lua, '-p', str(path)])
            counts['Lua'] += 1
        elif kind == '.sh':
            interpreter = shell if 'bash' in text.splitlines()[0] else required('sh')
            run([interpreter, '-n', str(path)])
            counts['shell'] += 1
        elif kind == '.fish':
            run([fish, '-n', str(path)])
            counts['Fish'] += 1
        elif kind == '.toml':
            tomllib.loads(text)
            counts['TOML'] += 1
        elif kind == '.json':
            json.loads(text)
            counts['JSON'] += 1
    print('PASS syntax: ' + ', '.join(f'{value} {key}' for key, value in counts.items()))
    for path in (ROOT / 'dot_config/menus').glob('*.menu'):
        ET.parse(path)
    validator = required('desktop-file-validate')
    for path in (ROOT / 'dot_local/share/applications').glob('*.desktop*'):
        if not path.name.endswith('.tmpl'):
            run([validator, str(path)])
    print('PASS menu XML and desktop entries')
    qml = sorted(str(p) for p in (ROOT / 'dot_config/quickshell').rglob('*') if p.suffix in ('.qml', '.js'))
    with tempfile.TemporaryDirectory(prefix='hyprdodz-check-') as directory:
        temporary = Path(directory)
        report = temporary / 'qml.json'
        run([lint, '--ignore-settings', '--max-warnings', '100000', '--json', str(report),
             '-I', str(ROOT / 'dot_config/quickshell'), *qml])
        parsed = json.loads(report.read_text())
        warnings = [w for item in parsed.get('files', []) for w in item.get('warnings', [])]
        errors = [w for w in warnings if w.get('type') == 'error']
        if errors:
            raise ValueError(f'QML errors: {errors}')
        print(f'PASS QML/JS syntax: {len(qml)} files; {len(warnings)} type-analysis warnings (Quickshell/context dependent)')
        home = temporary / 'home'
        home.mkdir()
        config = temporary / 'chezmoi.toml'
        config.write_text('[data]\nhostname = "validation"\ngpu = "none"\ndisplayName = "HyprDodz"\n')
        env = {**os.environ, 'HOME': str(home), 'XDG_CONFIG_HOME': str(home / '.config'),
               'XDG_STATE_HOME': str(home / '.local/state'), 'XDG_CACHE_HOME': str(home / '.cache'),
               'XDG_DATA_HOME': str(home / '.local/share'), 'PYTHONDONTWRITEBYTECODE': '1'}
        # promptStringOnce belongs to init, not execute-template. Initialize only
        # a disposable source containing this template, never the live home.
        init_source = temporary / 'init-source'
        init_source.mkdir()
        shutil.copy2(ROOT / '.chezmoi.toml.tmpl', init_source)
        run([chezmoi, '--config', str(config), '--config-format', 'toml', '--source', str(init_source),
             '--destination', str(home), '--no-tty', 'init', '--promptDefaults'], env=env)
        tomllib.loads(config.read_text())
        templates = sorted(p for p in ROOT.rglob('*.tmpl') if p.is_file() and p.name != '.chezmoi.toml.tmpl')
        for path in templates:
            rendered = run([chezmoi, '--config', str(config), '--config-format', 'toml', '--source', str(ROOT),
                            '--destination', str(home), 'execute-template'], env=env, data=path.read_text())
            if path.name.endswith('.toml.tmpl'):
                tomllib.loads(rendered)
            elif path.name.endswith('.json.tmpl'):
                json.loads(rendered)
            elif path.name.endswith('.sh.tmpl'):
                run([shell, '-n'], data=rendered)
        print(f'PASS templates: {len(templates) + 1} rendered with isolated machine data')
    local_links()
    run([sys.executable, '-B', 'scripts/test-desktop-helpers.py'])
    print('PASS desktop helper regression tests')
    print(run([sys.executable, '-B', 'scripts/test-mouse-rgb.py']).strip())
    print('Config checks passed. No live configs or devices were changed.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, ValueError, SyntaxError, ET.ParseError) as error:
        print(f'FAIL: {error}', file=sys.stderr)
        raise SystemExit(1)
