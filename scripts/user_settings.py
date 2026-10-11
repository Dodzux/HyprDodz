#!/usr/bin/env python3
"""Capture selected browser preferences without exporting account/profile data."""
import json
from pathlib import Path
import re


def browser_preferences(home):
    snapshots = {}
    for path in sorted((home / '.config/BraveSoftware/Brave-Browser').glob('*/Preferences')):
        original = json.loads(path.read_text())
        selected = {key: original[key] for key in (
            'accessibility', 'bookmark_bar', 'intl', 'spellcheck', 'vertical_tabs', 'webkit',
        ) if key in original}
        # Window geometry changes during ordinary use and is runtime state.
        browser = {key: value for key, value in original.get('browser', {}).items() if key in (
            'custom_chrome_frame', 'theme',
        )}
        if browser:
            selected['browser'] = browser
        brave = {key: value for key, value in original.get('brave', {}).items() if key in (
            'always_show_bookmark_bar_on_ntp', 'enable_media_router_on_restart', 'enable_window_closing_confirm',
        )}
        if brave:
            selected['brave'] = brave
        snapshots[str(path.relative_to(home))] = {'format': 'chromium-json', 'preferences': selected}

    prefixes = ('browser.tabs.', 'browser.toolbars.', 'browser.uiCustomization.',
                'font.', 'layout.css.', 'ui.', 'privacy.trackingprotection.')
    exact = {'browser.uidensity', 'general.autoScroll', 'extensions.activeThemeID',
             'toolkit.legacyUserProfileCustomizations.stylesheets'}
    for path in sorted((home / '.config/mozilla/firefox').glob('*/prefs.js')):
        selected = {}
        for match in re.finditer(r'^user_pref\(("(?:[^"\\]|\\.)*"),\s*(.*?)\);$', path.read_text(), re.M):
            key = json.loads(match[1])
            if key in exact or key.startswith(prefixes):
                selected[key] = json.loads(match[2])
        snapshots[str(path.relative_to(home))] = {'format': 'firefox-user-prefs', 'preferences': selected}
    return snapshots


def main():
    repo = Path(__file__).resolve().parent.parent
    output = repo / 'system/user/browser-preferences.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(browser_preferences(Path.home()), indent=2, ensure_ascii=False) + '\n')
    print(f'Wrote selected ordinary browser preferences to {output}')


if __name__ == '__main__':
    main()
