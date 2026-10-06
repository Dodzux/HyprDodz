#!/usr/bin/env python3
"""Restore the original directory modes that chezmoi attributes cannot encode."""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    home = Path.home()
    repo = Path(__file__).resolve().parent.parent
    modes = json.loads((repo / 'system/user/directory-permissions.json').read_text())
    for relative, mode in modes.items():
        path = home / relative
        if not relative.startswith('.config/') or '..' in Path(relative).parts:
            raise ValueError(f'Unexpected path in permission snapshot: {relative}')
        if not path.is_dir() or path.is_symlink():
            continue
        path.resolve().relative_to(home.resolve())
        if args.dry_run:
            print(f'chmod {mode} {path}')
        else:
            path.chmod(int(mode, 8))


if __name__ == '__main__':
    main()
