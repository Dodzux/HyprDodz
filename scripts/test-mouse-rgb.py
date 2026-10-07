#!/usr/bin/env python3
"""Regression tests for mouse SDK routing; all hardware commands are mocked."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


REPO = Path(__file__).resolve().parents[1]
MOCK = r'''#!/usr/bin/env python3
import json, os, sys, time
from pathlib import Path
root = Path(os.environ['TEST_ROOT'])
with (root / 'calls.jsonl').open('a') as stream:
    stream.write(json.dumps(sys.argv[1:]) + '\n')
query = '--list-detailed' in sys.argv
prefix = 'TEST_QUERY' if query else 'TEST_UPDATE'
if query and '--noautoconnect' in sys.argv:
    sys.exit(0)
if os.environ.get(prefix + '_SUPERSEDE') == '1':
    (Path(os.environ['XDG_RUNTIME_DIR']) / 'wallpaper-rgb.want').write_text('00FF00')
time.sleep(float(os.environ.get(prefix + '_DELAY', '0')))
if query:
    print(os.environ['TEST_LISTING'])
if os.environ.get(prefix + '_OUTPUT'):
    print(os.environ[prefix + '_OUTPUT'])
if os.environ.get(prefix + '_ERROR'):
    print(os.environ[prefix + '_ERROR'], file=sys.stderr)
sys.exit(int(os.environ.get(prefix + '_EXIT', '0')))
'''


def run_tests(script):
    observed = ("0: G305 Lightspeed Wireless Gaming Mouse\n"
                "  Modes: [Direct] Off Static 'Spectrum Cycle' Breathing\n"
                "  Zones: Primary\n  LEDs: Primary\n"
                "1: G305 Lightspeed Wireless Gaming Mouse\n"
                "  Modes: [Direct] Off Static 'Spectrum Cycle' Breathing\n"
                "2: Keyboard\n  Modes: [Static]")
    single = "0: G305\n  Modes: [Static]"
    cases = [
        ("observed duplicate entries; keyboard excluded", observed, {}, 0, True, [0, 1]),
        ("direct-only device", "0: G305\n  Modes: [Direct]", {}, 0, True, [0]),
        ("unsupported mode", "0: G305\n  Modes: [Breathing]", {}, 1, False, []),
        ("empty device list", "", {}, 1, False, []),
        ("query nonzero exit", single, {"TEST_QUERY_EXIT": "1"}, 1, False, []),
        ("update nonzero exit", single, {"TEST_UPDATE_EXIT": "1"}, 1, False, [0]),
        ("query error with zero exit", single, {"TEST_QUERY_OUTPUT": "Error: SDK query failed"}, 1, False, []),
        ("update stdout error with zero exit", single, {"TEST_UPDATE_OUTPUT": "Error: Mode unavailable"}, 1, False, [0]),
        ("update stderr error with zero exit", single, {"TEST_UPDATE_ERROR": "[ERROR] Device unavailable"}, 1, False, [0]),
        ("invalid colour count with zero exit", single, {"TEST_UPDATE_OUTPUT": "Wrong number of colors specified for mode Static"}, 1, False, [0]),
        ("superseded during query", single, {"TEST_QUERY_SUPERSEDE": "1"}, 0, False, []),
        ("superseded during update", single, {"TEST_UPDATE_SUPERSEDE": "1"}, 0, False, [0]),
        ("stale generation", single, {"TEST_STALE": "1"}, 0, False, []),
        ("hash-prefixed colour", single, {"TEST_COLOUR": "#d14265"}, 0, True, [0]),
        ("invalid input", single, {"TEST_COLOUR": "not-a-colour"}, 2, False, []),
        ("symlink config refused", single, {"TEST_CONFIG_SYMLINK": "1"}, 1, False, []),
        ("query timeout", single, {"TEST_QUERY_DELAY": "6"}, 1, False, []),
        ("update timeout", single, {"TEST_UPDATE_DELAY": "6"}, 1, False, [0]),
    ]
    with tempfile.TemporaryDirectory(prefix="mouse-rgb-tests-", dir="/tmp") as directory:
        root = Path(directory)
        bin_dir = root / "bin"
        bin_dir.mkdir()
        mock = bin_dir / "openrgb"
        mock.write_text(MOCK)
        mock.chmod(0o700)
        for number, (name, listing, extra, exit_code, applied, indices) in enumerate(cases):
            case, runtime, env = fixture(root / str(number), bin_dir, listing, extra)
            if "TEST_CONFIG_SYMLINK" in extra:
                (runtime / "hypr-mouse-sdk-client").symlink_to(case)
            result = subprocess.run(["bash", str(script), extra.get("TEST_COLOUR", "d14265"), "current"],
                                    env=env, capture_output=True, text=True, timeout=12)
            assert result.returncode == exit_code, (name, result.returncode, result.stderr)
            marker = runtime / "wallpaper-rgb.mouse.applied"
            assert marker.exists() == applied, name
            calls = get_calls(case)
            updates = [call for call in calls if "--list-detailed" not in call]
            actual = [int(call[i + 1]) for call in updates for i, arg in enumerate(call) if arg == "--device"]
            assert actual == indices, (name, actual)
            for call in calls:
                assert "--nodetect" in call and "--client" in call, name
                assert "--noautoconnect" not in call, name
                assert call[call.index("--client") + 1] == "127.0.0.1:6742", name
                assert call[call.index("--config") + 1] == str(runtime / "hypr-mouse-sdk-client"), name
            assert "Error: Mode unavailable" not in result.stdout + result.stderr, name
            if applied:
                assert marker.read_text().strip() == "D14265", name
            print("PASS", name)
        integration(root, bin_dir, script, observed)
    print(f"Passed {len(cases) + 1} tests; no real hardware or user configs accessed.")


def fixture(case, bin_dir, listing, extra):
    case.mkdir()
    runtime = case / "runtime"
    runtime.mkdir()
    (runtime / "wallpaper-rgb.want").write_text("D14265")
    (runtime / "sync_border.token").write_text("new" if "TEST_STALE" in extra else "current")
    env = {key: value for key, value in os.environ.items() if not key.startswith("TEST_")}
    env.update(PATH=str(bin_dir) + ":" + os.environ["PATH"], TEST_ROOT=str(case),
               XDG_RUNTIME_DIR=str(runtime), TEST_LISTING=listing, **extra)
    return case, runtime, env


def get_calls(case):
    log = case / "calls.jsonl"
    return [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []


def integration(root, bin_dir, script, listing):
    case, runtime, env = fixture(root / "integration", bin_dir, listing, {})
    script_dir = case / "scripts"
    script_dir.mkdir()
    outer = script_dir / "openrgb_color.sh"
    outer.write_bytes((REPO / "dot_config/hypr/scripts/executable_openrgb_color.sh").read_bytes())
    outer.chmod(0o700)
    mouse = script_dir / "openrgb_mouse_color.sh"
    shutil.copyfile(script, mouse)
    mouse.chmod(0o700)
    # Stub only the physical keyboard command and machine identification.
    (script_dir / "asus_keyboard_color.py").write_text("raise SystemExit(0)\n")
    cat = bin_dir / "cat"
    real_cat = shutil.which("cat")
    cat.write_text(f'''#!/usr/bin/env bash
if [[ "${{1:-}}" == /sys/class/dmi/id/board_name ]]; then
    printf '%s\\n' G614PH
else
    exec "{real_cat}" "$@"
fi
''')
    cat.chmod(0o700)
    result = subprocess.run([str(outer), "d14265", "current"], env=env,
                            capture_output=True, text=True, timeout=14)
    assert result.returncode == 0, ("parent integration", result.stderr)
    assert (runtime / "wallpaper-rgb.mouse.applied").read_text().strip() == "D14265"
    assert (runtime / "wallpaper-rgb.keyboard.applied").read_text().strip() == "D14265"
    assert len(get_calls(case)) == 2, "parent should query and update SDK exactly once"
    print("PASS real parent script dispatch (hardware mocked)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--script", type=Path,
                        default=REPO / "dot_config/hypr/scripts/executable_openrgb_mouse_color.sh")
    run_tests(parser.parse_args().script.resolve())
