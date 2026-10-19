#!/usr/bin/env python3
"""Check desktop state validation and workspace actions using temporary/mocked data."""
import copy
import importlib.util
import json
from pathlib import Path
import re
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'dot_config/quickshell/scripts'))
import desktop_data
import desktop_extras


class DesktopHelpers(unittest.TestCase):
    def test_layout_requires_every_control_once(self):
        for payload in ({'controls': desktop_extras.CONTROLS + ['audio']}, {'status': []}, {'controls': ['unknown']}):
            with self.subTest(payload=payload), self.assertRaises(ValueError):
                desktop_extras.preferences(payload)

    def test_labels_reject_invalid_names(self):
        for labels in ({'0': 'invalid'}, {'1': 'x' * 25}, {'1': 'line\nbreak'}):
            with self.subTest(labels=labels), self.assertRaises(ValueError):
                desktop_extras.preferences({'labels': labels})
        self.assertEqual(desktop_extras.preferences({'favorites': ['one', 'one', 'two']})['favorites'], ['one', 'two'])

    def test_repeated_wallpaper_keeps_undo(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(desktop_extras, 'STATE', Path(directory) / 'state'):
            previous, current = Path(directory) / 'one image.png', Path(directory) / 'two image.png'
            previous.touch(); current.touch()
            desktop_extras.record_wallpaper(str(current), str(previous))
            desktop_extras.record_wallpaper(str(current), str(current))
            saved = desktop_extras.read('wallpaper-history.json', {})
            self.assertEqual(saved, {'current': str(current), 'previous': str(previous)})
            with patch.object(desktop_extras.subprocess, 'Popen') as launch:
                desktop_extras.undo_wallpaper()
                self.assertEqual(launch.call_args.args[0][-1], str(previous))

    def test_stale_window_cannot_move(self):
        clients = [{'address': '0xaa', 'mapped': True, 'hidden': False, 'pinned': False,
                    'class': 'kitty', 'pid': 20, 'workspace': {'id': 1, 'name': '1'}}]
        with patch.object(desktop_data, 'hypr_json', return_value=clients), patch.object(desktop_data, 'dispatch') as dispatch:
            with self.assertRaises(ValueError):
                desktop_extras.workspace_action({'workspace': 2, 'action': 'move', 'expectedAddress': '0xaa', 'expectedPid': 99})
            dispatch.assert_not_called()

    def test_gather_rolls_back_if_a_move_fails(self):
        original = [{'address': '0xaa', 'mapped': True, 'hidden': False, 'pinned': False, 'class': 'kitty', 'workspace': {'id': 1, 'name': '1'}},
                    {'address': '0xbb', 'mapped': True, 'hidden': False, 'pinned': False, 'class': 'kitty', 'workspace': {'id': 2, 'name': '2'}}]
        state, calls = copy.deepcopy(original), []
        def dispatch(code):
            calls.append(code)
            if len(calls) == 2:
                raise RuntimeError('mock dispatch failure')
            target, address = re.search(r'workspace=(\d+), follow=false, window="address:(0x[0-9a-f]+)"', code).groups()
            next(c for c in state if c['address'] == address)['workspace'] = {'id': int(target), 'name': target}
        with patch.object(desktop_data, 'hypr_json', side_effect=lambda kind: copy.deepcopy(state)), patch.object(desktop_data, 'dispatch', side_effect=dispatch):
            with self.assertRaises(RuntimeError):
                desktop_extras.workspace_action({'workspace': 3, 'action': 'gather', 'expectedAddress': '0xaa'})
        self.assertEqual(state, original)
        self.assertEqual(len(calls), 3)

    def test_qt_palette_preserves_disabled_colors(self):
        spec = importlib.util.spec_from_file_location('color_sync', ROOT / 'dot_config/hypr/scripts/executable_sync_border.py')
        sync = importlib.util.module_from_spec(spec); spec.loader.exec_module(sync)
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory); (config / 'colors').mkdir()
            scheme = config / 'colors/quickshell.conf'
            row = ', '.join(['#ff222222'] * 21)
            scheme.write_text('[ColorScheme]\n' + '\n'.join(name + '=' + row for name in ('active_colors', 'inactive_colors', 'disabled_colors')) + '\n')
            sync.update_qt_palette('ffffff', str(config))
            roles = {line.split('=', 1)[0]: line.split('=', 1)[1].split(', ') for line in scheme.read_text().splitlines() if '=' in line}
            self.assertEqual(len(roles['active_colors']), 22)
            self.assertEqual(roles['active_colors'][12:14], ['#ffffffff', '#ff111111'])
            self.assertEqual(roles['disabled_colors'][21], '#ff222222')
            stamp = scheme.stat().st_mtime_ns
            sync.update_qt_palette('ffffff', str(config))
            self.assertEqual(scheme.stat().st_mtime_ns, stamp)


if __name__ == '__main__':
    unittest.main()
