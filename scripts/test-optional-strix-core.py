#!/usr/bin/env python3
"""Check the opt-in install flow with fake build/package tools only."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
COMMIT = "c10e82c02373861ee3c2987f282b8cdc509ac8a3"
MOCK = r'''
import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
args = sys.argv[1:]
with Path(os.environ['TEST_LOG']).open('a') as stream:
    stream.write(json.dumps({'tool': name, 'args': args, 'cwd': os.getcwd()}) + '\n')
if name == 'git':
    if 'clone' in args:
        if os.environ.get('CLONE_FAIL'): sys.exit(9)
        assert args[args.index('--branch') + 1] == 'v0.3.6'
        assert args[-2] == 'https://github.com/Dodzux/Strix-Core.git'
        (Path(args[-1]) / 'packaging').mkdir(parents=True)
    else:
        assert args[0] == '-C' and args[-2:] == ['rev-parse', 'HEAD']
        print(os.environ['TEST_COMMIT'])
elif name == 'makepkg':
    assert args == ['--syncdeps', '--install'] and Path.cwd().name == 'packaging'
    sys.exit(int(os.environ.get('BUILD_EXIT', '0')))
elif name == 'chezmoi':
    if args[0] == 'execute-template':
        print('none' if '.gpu' in args[1] else 'Fixture User')
elif name == 'which':
    print(Path(os.environ['TEST_BIN']) / args[0])
elif name == 'optional-install':
    sys.exit(int(os.environ.get('OPTIONAL_EXIT', '0')))
elif name == 'cat':
    if not args:
        sys.stdout.write(sys.stdin.read())
    else:
        assert args == ['/proc/sys/kernel/hostname']
        print('fixture-host')
elif name in ('strix-core', 'chsh'):
    raise AssertionError('Unexpected app launch or account change')
'''


class OptionalInstall(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="strix-install-tests-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls.jsonl"
        self.home = self.root / "home"
        self.home.mkdir()
        self.builds = self.root / "builds"
        self.builds.mkdir()
        for name in ("git", "pacman", "makepkg", "fakeroot", "sudo", "chezmoi",
                     "systemctl", "fc-cache", "which", "fish", "cat", "strix-core", "chsh"):
            target = self.bin / name
            target.write_text(f"#!{sys.executable}\n" + MOCK)
            target.chmod(0o700)
        self.env = {**os.environ, "PATH": str(self.bin) + ":" + os.environ["PATH"],
                    "HOME": str(self.home), "TMPDIR": str(self.builds),
                    "TEST_LOG": str(self.log), "TEST_BIN": str(self.bin),
                    "TEST_COMMIT": COMMIT, "SHELL": str(self.bin / "fish")}

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def install(self, *args, **environment):
        return subprocess.run(["/usr/bin/bash", str(ROOT / "scripts/install-strix-core.sh"), *args],
                              env={**self.env, **environment}, capture_output=True, text=True, timeout=15)

    def test_help_does_not_build(self):
        result = self.install("--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("v0.3.6", result.stdout)
        self.assertFalse(any(c["tool"] in ("git", "makepkg") for c in self.calls()))

    def test_invalid_option_does_not_build(self):
        self.assertEqual(self.install("--unknown").returncode, 2)
        self.assertFalse(any(c["tool"] in ("git", "makepkg") for c in self.calls()))

    @unittest.skipIf(os.geteuid() == 0, "makepkg must run as a normal user")
    def test_verified_release_is_built_without_starting_app(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([c["tool"] for c in self.calls()], ["git", "git", "makepkg"])
        self.assertFalse(list(self.builds.iterdir()))

    @unittest.skipIf(os.geteuid() == 0, "makepkg must run as a normal user")
    def test_revision_mismatch_stops_before_build(self):
        result = self.install(TEST_COMMIT="0" * 40)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(c["tool"] == "makepkg" for c in self.calls()))
        self.assertFalse(list(self.builds.iterdir()))

    @unittest.skipIf(os.geteuid() == 0, "makepkg must run as a normal user")
    def test_build_failure_is_reported_and_cleaned(self):
        self.assertEqual(self.install(BUILD_EXIT="7").returncode, 7)
        self.assertFalse(list(self.builds.iterdir()))

    @unittest.skipIf(os.geteuid() == 0, "makepkg must run as a normal user")
    def test_clone_failure_does_not_build(self):
        self.assertEqual(self.install(CLONE_FAIL="1").returncode, 9)
        self.assertFalse(any(c["tool"] == "makepkg" for c in self.calls()))
        self.assertFalse(list(self.builds.iterdir()))

    def bootstrap(self, *args, **environment):
        checkout = self.root / "checkout"
        (checkout / "scripts").mkdir(parents=True)
        (checkout / "packages").mkdir()
        (checkout / "packages/10-test.txt").write_text("fixture-package\n")
        (self.home / ".themes/Graphite-Dark").mkdir(parents=True)
        shutil.copy2(ROOT / "scripts/bootstrap.sh", checkout / "scripts/bootstrap.sh")
        (checkout / "scripts/install-strix-core.sh").write_text('"$TEST_BIN/optional-install"\n')
        (checkout / "scripts/restore-config-permissions.py").write_text("# Fixture: no permission changes.\n")
        optional = self.bin / "optional-install"
        optional.write_text(f"#!{sys.executable}\n" + MOCK)
        optional.chmod(0o700)
        return subprocess.run(["/usr/bin/bash", str(checkout / "scripts/bootstrap.sh"), *args],
                              env={**self.env, **environment}, capture_output=True, text=True, timeout=20)

    def test_default_bootstrap_skips_strix_core(self):
        result = self.bootstrap()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any(c["tool"] == "optional-install" for c in self.calls()))

    def test_explicit_flag_installs_strix_core(self):
        result = self.bootstrap("--with-strix-core")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(sum(c["tool"] == "optional-install" for c in self.calls()), 1)
        self.assertTrue(any(c["tool"] == "sudo" and "base-devel" in c["args"] for c in self.calls()))

    def test_bootstrap_help_has_no_side_effects(self):
        result = self.bootstrap("--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [])

    def test_optional_failure_does_not_stop_desktop_setup(self):
        result = self.bootstrap("--with-strix-core", OPTIONAL_EXIT="7")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Strix Core install failed", result.stdout)
        self.assertTrue(any(c["tool"] == "chezmoi" and c["args"] == ["apply", "--force"] for c in self.calls()))


if __name__ == "__main__":
    unittest.main()
