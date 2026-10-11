# Configuration coverage

Checked: 2026-10-11 18:10 UTC.

This compares live configuration files and symlinks with chezmoi’s rendered state,
and also searches for files that chezmoi does not manage. Source filenames such as
`dot_config`, `private_`, `executable_`, and `.tmpl` encode deployment behavior;
they are not expected to look identical to the live folder names.

**51246 tracked entries checked; 0 content/link differences;
1291 unexplained missing entries.**

0 malformed live symlink target(s) are normalized by chezmoi; see below.

| Live folder/file | Tracked | Different | Captured separately | Excluded | Missing |
| --- | ---: | ---: | ---: | ---: | ---: |
| `.bash_logout` | 1 | 0 | 0 | 0 | 0 |
| `.bash_profile` | 1 | 0 | 0 | 0 | 0 |
| `.bashrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/BraveSoftware` | 0 | 0 | 0 | 4337 | 0 |
| `.config/Codex` | 0 | 0 | 0 | 53 | 1287 |
| `.config/Kvantum` | 6 | 0 | 0 | 0 | 0 |
| `.config/OpenRGB` | 3 | 0 | 0 | 11 | 0 |
| `.config/QtProject` | 1 | 0 | 0 | 0 | 0 |
| `.config/QtProject.conf` | 1 | 0 | 0 | 0 | 0 |
| `.config/VirtualBox` | 1 | 0 | 0 | 25 | 0 |
| `.config/arkrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/autostart` | 1 | 0 | 0 | 0 | 0 |
| `.config/baloofileinformationrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/btop` | 4 | 0 | 0 | 0 | 0 |
| `.config/cachyos` | 1 | 0 | 0 | 1 | 0 |
| `.config/cachyos-hello.json` | 1 | 0 | 0 | 0 | 0 |
| `.config/chezmoi` | 0 | 0 | 0 | 2 | 0 |
| `.config/dconf` | 0 | 0 | 1 | 0 | 0 |
| `.config/discord` | 1 | 0 | 0 | 7459 | 0 |
| `.config/dolphinrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/fish` | 13 | 0 | 0 | 1 | 0 |
| `.config/gh` | 1 | 0 | 0 | 1 | 0 |
| `.config/ghostty` | 3 | 0 | 0 | 0 | 0 |
| `.config/gtk-3.0` | 3 | 0 | 0 | 0 | 0 |
| `.config/gtk-4.0` | 4 | 0 | 0 | 0 | 0 |
| `.config/hypr` | 39 | 0 | 0 | 4 | 1 |
| `.config/inkscape` | 12 | 0 | 0 | 1 | 0 |
| `.config/kdeglobals` | 1 | 0 | 0 | 0 | 0 |
| `.config/kiorc` | 1 | 0 | 0 | 0 | 0 |
| `.config/kitty` | 5 | 0 | 0 | 1 | 0 |
| `.config/micro` | 153 | 0 | 0 | 0 | 0 |
| `.config/mimeapps.list` | 1 | 0 | 0 | 0 | 0 |
| `.config/mozilla` | 0 | 0 | 0 | 188 | 0 |
| `.config/mpv` | 1 | 0 | 0 | 0 | 0 |
| `.config/nvim` | 14 | 0 | 0 | 0 | 0 |
| `.config/nwg-look` | 1 | 0 | 0 | 0 | 0 |
| `.config/obs-studio` | 7 | 0 | 0 | 8 | 0 |
| `.config/obsidian` | 1 | 0 | 0 | 74 | 0 |
| `.config/opencode` | 0 | 0 | 0 | 0 | 1 |
| `.config/pavucontrol.ini` | 1 | 0 | 0 | 0 | 0 |
| `.config/pulse` | 0 | 0 | 0 | 1 | 0 |
| `.config/qalculate` | 1 | 0 | 0 | 0 | 0 |
| `.config/qt6ct` | 3 | 0 | 0 | 0 | 0 |
| `.config/quickshell` | 45 | 0 | 0 | 4 | 0 |
| `.config/scripts` | 1 | 0 | 0 | 0 | 0 |
| `.config/session` | 0 | 0 | 0 | 1 | 0 |
| `.config/shelly` | 2 | 0 | 0 | 0 | 0 |
| `.config/starship.toml` | 1 | 0 | 0 | 0 | 0 |
| `.config/starshipfork.toml` | 1 | 0 | 0 | 0 | 0 |
| `.config/systemd` | 17 | 0 | 0 | 0 | 0 |
| `.config/trashrc` | 1 | 0 | 0 | 0 | 0 |
| `.config/user-dirs.dirs` | 1 | 0 | 0 | 0 | 0 |
| `.config/uwsm` | 1 | 0 | 0 | 0 | 0 |
| `.config/xsettingsd` | 1 | 0 | 0 | 0 | 0 |
| `.config/yazi` | 4 | 0 | 0 | 0 | 0 |
| `.gitconfig` | 1 | 0 | 0 | 0 | 0 |
| `.gtkrc-2.0` | 1 | 0 | 0 | 0 | 0 |
| `.icons` | 1 | 0 | 0 | 0 | 0 |
| `.local/bin` | 3 | 0 | 0 | 1 | 2 |
| `.local/share/applications` | 2 | 0 | 0 | 1 | 0 |
| `.local/share/color-schemes` | 4 | 0 | 0 | 0 | 0 |
| `.local/share/icons` | 46420 | 0 | 0 | 615 | 0 |
| `.local/share/nwg-look` | 1 | 0 | 0 | 0 | 0 |
| `.local/share/themes` | 3786 | 0 | 0 | 0 | 0 |
| `.nvidia-settings-rc` | 1 | 0 | 0 | 0 | 0 |
| `.themes` | 631 | 0 | 0 | 0 | 0 |
| `.zshrc` | 1 | 0 | 0 | 0 | 0 |
| `Pictures/Wallpapers` | 28 | 0 | 0 | 1 | 0 |

## Exclusions and separate captures

Private accounts/sessions, caches, downloaded applications, logs, generated
cursor variants, and backups stay local. Selected ordinary Brave/Firefox
preferences are in `system/user/browser-preferences.json`; this is a partial
settings snapshot, not a browser-profile backup. dconf is captured as text
in `system/user/dconf.ini.tmpl` rather than copying its binary database.

| Location | Entries | Reason |
| --- | ---: | --- |
| `.config/BraveSoftware` | 4337 | Browser profile, accounts, history, caches; selected ordinary preferences exported separately |
| `.config/Codex` | 52 | Application log |
| `.config/Codex` | 1 | Backup file |
| `.config/Codex` | 1287 | Not managed and no exclusion applies |
| `.config/OpenRGB` | 10 | Application logs |
| `.config/OpenRGB` | 1 | Previous configuration experiment/backup |
| `.config/VirtualBox` | 25 | VirtualBox runtime registrations, logs, or backups |
| `.config/cachyos` | 1 | Application log |
| `.config/chezmoi` | 2 | Machine-local chezmoi configuration and persistent database |
| `.config/dconf` | 1 | dconf settings exported to system/user/dconf.ini.tmpl |
| `.config/discord` | 7459 | Discord account/session data, caches, installed application files |
| `.config/fish` | 1 | Fish-generated universal-variable state |
| `.config/gh` | 1 | GitHub authentication/account data |
| `.config/hypr` | 1 | Not managed and no exclusion applies |
| `.config/hypr` | 4 | Python bytecode cache |
| `.config/inkscape` | 1 | Application log |
| `.config/kitty` | 1 | Previous configuration experiment/backup |
| `.config/mozilla` | 188 | Firefox profile, accounts, history, caches; selected ordinary preferences exported separately |
| `.config/obs-studio` | 1 | Application logs |
| `.config/obs-studio` | 1 | Backup file |
| `.config/obs-studio` | 4 | Downloaded OBS service catalog |
| `.config/obs-studio` | 1 | OBS WebSocket configuration contains a password |
| `.config/obs-studio` | 1 | OBS performance/profiler output |
| `.config/obsidian` | 74 | Obsidian account/session data, caches, installed application files |
| `.config/opencode` | 1 | Not managed and no exclusion applies |
| `.config/pulse` | 1 | PulseAudio authentication cookie |
| `.config/quickshell` | 4 | Previous configuration experiment/backup |
| `.config/session` | 1 | Restorable application session state |
| `.local/bin` | 1 | Installed Codex executable; launcher configuration is tracked |
| `.local/bin` | 2 | Not managed and no exclusion applies |
| `.local/share/applications` | 1 | Generated desktop-entry cache |
| `.local/share/icons` | 615 | Generated wallpaper cursor variant; base theme is tracked |
| `Pictures/Wallpapers` | 1 | Wallpaper exceeds 100 MiB; kept local by request |

## Differences

None.

## Unexplained missing entries

- `.config/Codex/.codex-tpp-local-executor-installation-id`
- `.config/Codex/ActorSafetyLists/9.8200.9609/_metadata/verified_contents.json`
- `.config/Codex/ActorSafetyLists/9.8200.9609/listdata.json`
- `.config/Codex/ActorSafetyLists/9.8200.9609/manifest.json`
- `.config/Codex/AmountExtractionHeuristicRegexes/4/_metadata/verified_contents.json`
- `.config/Codex/AmountExtractionHeuristicRegexes/4/heuristic_regexes.binarypb`
- `.config/Codex/AmountExtractionHeuristicRegexes/4/manifest.json`
- `.config/Codex/BrowserMetrics-spare.pma`
- `.config/Codex/CaptchaProviders/8.5419.4434/_metadata/verified_contents.json`
- `.config/Codex/CaptchaProviders/8.5419.4434/captcha_providers.json`
- `.config/Codex/CaptchaProviders/8.5419.4434/manifest.json`
- `.config/Codex/CertificateRevocation/10828/LICENSE`
- `.config/Codex/CertificateRevocation/10828/_metadata/verified_contents.json`
- `.config/Codex/CertificateRevocation/10828/crl-set`
- `.config/Codex/CertificateRevocation/10828/manifest.json`
- `.config/Codex/Crash Reports/attachments`
- `.config/Codex/Crash Reports/completed`
- `.config/Codex/Crash Reports/new`
- `.config/Codex/Crash Reports/pending`
- `.config/Codex/Crash Reports/settings.dat`
- `.config/Codex/Crowd Deny/2026.10.8.62/Preload Data`
- `.config/Codex/Crowd Deny/2026.10.8.62/_metadata/verified_contents.json`
- `.config/Codex/Crowd Deny/2026.10.8.62/manifest.json`
- `.config/Codex/Default/.org.chromium.Chromium.Network Persistent State.6f2l9J`
- `.config/Codex/Default/.org.chromium.Chromium.Network Persistent State.7UVMJh`
- `.config/Codex/Default/.org.chromium.Chromium.Network Persistent State.GWlhJg`
- `.config/Codex/Default/.org.chromium.Chromium.Network Persistent State.OhvzMt`
- `.config/Codex/Default/Account Web Data`
- `.config/Codex/Default/Account Web Data-journal`
- `.config/Codex/Default/Affiliation Database`
- `.config/Codex/Default/Affiliation Database-journal`
- `.config/Codex/Default/AutofillAiModelCache/LOCK`
- `.config/Codex/Default/AutofillAiModelCache/LOG`
- `.config/Codex/Default/AutofillAiModelCache/LOG.old`
- `.config/Codex/Default/AutofillStrikeDatabase/LOCK`
- `.config/Codex/Default/AutofillStrikeDatabase/LOG`
- `.config/Codex/Default/AutofillStrikeDatabase/LOG.old`
- `.config/Codex/Default/BookmarkMergedSurfaceOrdering`
- `.config/Codex/Default/BudgetDatabase/LOCK`
- `.config/Codex/Default/BudgetDatabase/LOG`
- `.config/Codex/Default/BudgetDatabase/LOG.old`
- `.config/Codex/Default/ClientCertificates/LOCK`
- `.config/Codex/Default/ClientCertificates/LOG`
- `.config/Codex/Default/ClientCertificates/LOG.old`
- `.config/Codex/Default/Cookies`
- `.config/Codex/Default/Cookies-journal`
- `.config/Codex/Default/DIPS`
- `.config/Codex/Default/DIPS-wal`
- `.config/Codex/Default/DawnGraphiteCache/data_0`
- `.config/Codex/Default/DawnGraphiteCache/data_1`
- `.config/Codex/Default/DawnGraphiteCache/data_2`
- `.config/Codex/Default/DawnGraphiteCache/data_3`
- `.config/Codex/Default/DawnGraphiteCache/index`
- `.config/Codex/Default/DawnWebGPUCache/data_0`
- `.config/Codex/Default/DawnWebGPUCache/data_1`
- `.config/Codex/Default/DawnWebGPUCache/data_2`
- `.config/Codex/Default/DawnWebGPUCache/data_3`
- `.config/Codex/Default/DawnWebGPUCache/index`
- `.config/Codex/Default/Extension Rules/CURRENT`
- `.config/Codex/Default/Extension Rules/LOCK`
- `.config/Codex/Default/Extension Rules/LOG`
- `.config/Codex/Default/Extension Rules/MANIFEST-000001`
- `.config/Codex/Default/Extension Scripts/CURRENT`
- `.config/Codex/Default/Extension Scripts/LOCK`
- `.config/Codex/Default/Extension Scripts/LOG`
- `.config/Codex/Default/Extension Scripts/MANIFEST-000001`
- `.config/Codex/Default/Extension State/CURRENT`
- `.config/Codex/Default/Extension State/LOCK`
- `.config/Codex/Default/Extension State/LOG`
- `.config/Codex/Default/Extension State/LOG.old`
- `.config/Codex/Default/Extension State/MANIFEST-000001`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/128.png`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/af/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/am/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ar/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/as/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/az/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/be/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bg/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bn/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ca/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cs/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cy/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/da/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/de/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/el/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_CA/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_GB/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_US/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es_419/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/et/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/eu/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fa/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fi/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fil/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr_CA/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gl/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gu/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hi/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hr/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hu/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hy/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/id/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/is/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/it/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/iw/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ja/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ka/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kk/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/km/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kn/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ko/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lo/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lt/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lv/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mk/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ml/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mn/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mr/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ms/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/my/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ne/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/nl/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/no/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/or/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pa/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pl/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_BR/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_PT/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ro/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ru/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/si/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sk/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sl/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sq/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sr/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sv/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sw/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ta/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/te/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/th/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/tr/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uk/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ur/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uz/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/vi/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_CN/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_HK/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_TW/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zu/messages.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/computed_hashes.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/verified_contents.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/dasherSettingSchema.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/manifest.json`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument.html`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument_main.js`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/page_embed_script.js`
- `.config/Codex/Default/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/service_worker_bin_prod.js`
- `.config/Codex/Default/Favicons`
- `.config/Codex/Default/Favicons-journal`
- `.config/Codex/Default/Feature Engagement Tracker/AvailabilityDB/LOCK`
- `.config/Codex/Default/Feature Engagement Tracker/AvailabilityDB/LOG`
- `.config/Codex/Default/Feature Engagement Tracker/AvailabilityDB/LOG.old`
- `.config/Codex/Default/Feature Engagement Tracker/EventDB/LOCK`
- `.config/Codex/Default/Feature Engagement Tracker/EventDB/LOG`
- `.config/Codex/Default/Feature Engagement Tracker/EventDB/LOG.old`
- `.config/Codex/Default/GCM Store/CURRENT`
- `.config/Codex/Default/GCM Store/LOCK`
- `.config/Codex/Default/GCM Store/LOG`
- `.config/Codex/Default/GCM Store/LOG.old`
- `.config/Codex/Default/GCM Store/MANIFEST-000001`
- `.config/Codex/Default/GPUCache/data_0`
- `.config/Codex/Default/GPUCache/data_1`
- `.config/Codex/Default/GPUCache/data_2`
- `.config/Codex/Default/GPUCache/data_3`
- `.config/Codex/Default/GPUCache/f_000001`
- `.config/Codex/Default/GPUCache/index`
- `.config/Codex/Default/History`
- `.config/Codex/Default/History-journal`
- `.config/Codex/Default/IndexedDB/app_-_0.indexeddb.blob/1/00/2`
- `.config/Codex/Default/IndexedDB/app_-_0.indexeddb.leveldb/CURRENT`
- `.config/Codex/Default/IndexedDB/app_-_0.indexeddb.leveldb/LOCK`
- `.config/Codex/Default/IndexedDB/app_-_0.indexeddb.leveldb/LOG`
- `.config/Codex/Default/IndexedDB/app_-_0.indexeddb.leveldb/LOG.old`
- `.config/Codex/Default/IndexedDB/app_-_0.indexeddb.leveldb/MANIFEST-000001`
- `.config/Codex/Default/LOCK`
- `.config/Codex/Default/LOG`
- `.config/Codex/Default/LOG.old`
- `.config/Codex/Default/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/CURRENT`
- `.config/Codex/Default/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOCK`
- `.config/Codex/Default/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG`
- `.config/Codex/Default/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG.old`
- `.config/Codex/Default/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/MANIFEST-000001`
- `.config/Codex/Default/Local Storage/leveldb/CURRENT`
- `.config/Codex/Default/Local Storage/leveldb/LOCK`
- `.config/Codex/Default/Local Storage/leveldb/LOG`
- `.config/Codex/Default/Local Storage/leveldb/LOG.old`
- `.config/Codex/Default/Local Storage/leveldb/MANIFEST-000001`
- `.config/Codex/Default/Login Data`
- `.config/Codex/Default/Login Data For Account`
- `.config/Codex/Default/Login Data For Account-journal`
- `.config/Codex/Default/Login Data-journal`
- `.config/Codex/Default/MediaDeviceSalts`
- `.config/Codex/Default/MediaDeviceSalts-journal`
- `.config/Codex/Default/Network Persistent State`
- `.config/Codex/Default/Partitions/codex-browser-app/Account Web Data`
- `.config/Codex/Default/Partitions/codex-browser-app/Account Web Data-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Affiliation Database`
- `.config/Codex/Default/Partitions/codex-browser-app/Affiliation Database-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/AutofillAiModelCache/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/AutofillAiModelCache/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/AutofillAiModelCache/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/AutofillStrikeDatabase/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/AutofillStrikeDatabase/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/AutofillStrikeDatabase/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/BookmarkMergedSurfaceOrdering`
- `.config/Codex/Default/Partitions/codex-browser-app/BudgetDatabase/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/BudgetDatabase/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/BudgetDatabase/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/ClientCertificates/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/ClientCertificates/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/ClientCertificates/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Cookies`
- `.config/Codex/Default/Partitions/codex-browser-app/Cookies-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/DIPS`
- `.config/Codex/Default/Partitions/codex-browser-app/DIPS-wal`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnGraphiteCache/data_0`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnGraphiteCache/data_1`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnGraphiteCache/data_2`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnGraphiteCache/data_3`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnGraphiteCache/index`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnWebGPUCache/data_0`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnWebGPUCache/data_1`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnWebGPUCache/data_2`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnWebGPUCache/data_3`
- `.config/Codex/Default/Partitions/codex-browser-app/DawnWebGPUCache/index`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Rules/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Rules/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Rules/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Rules/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Scripts/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Scripts/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Scripts/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension Scripts/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension State/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension State/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension State/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension State/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Extension State/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/128.png`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/af/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/am/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ar/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/as/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/az/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/be/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bg/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bn/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ca/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cs/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cy/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/da/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/de/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/el/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_CA/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_GB/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_US/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es_419/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/et/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/eu/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fa/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fi/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fil/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr_CA/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gl/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gu/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hi/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hr/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hu/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hy/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/id/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/is/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/it/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/iw/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ja/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ka/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kk/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/km/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kn/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ko/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lo/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lt/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lv/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mk/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ml/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mn/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mr/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ms/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/my/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ne/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/nl/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/no/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/or/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pa/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pl/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_BR/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_PT/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ro/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ru/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/si/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sk/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sl/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sq/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sr/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sv/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sw/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ta/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/te/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/th/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/tr/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uk/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ur/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uz/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/vi/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_CN/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_HK/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_TW/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zu/messages.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/computed_hashes.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/verified_contents.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/dasherSettingSchema.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/manifest.json`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument.html`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument_main.js`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/page_embed_script.js`
- `.config/Codex/Default/Partitions/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/service_worker_bin_prod.js`
- `.config/Codex/Default/Partitions/codex-browser-app/Favicons`
- `.config/Codex/Default/Partitions/codex-browser-app/Favicons-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Feature Engagement Tracker/AvailabilityDB/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Feature Engagement Tracker/AvailabilityDB/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Feature Engagement Tracker/AvailabilityDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Feature Engagement Tracker/EventDB/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Feature Engagement Tracker/EventDB/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Feature Engagement Tracker/EventDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/GCM Store/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/GCM Store/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/GCM Store/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/GCM Store/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/GCM Store/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/GPUCache/data_0`
- `.config/Codex/Default/Partitions/codex-browser-app/GPUCache/data_1`
- `.config/Codex/Default/Partitions/codex-browser-app/GPUCache/data_2`
- `.config/Codex/Default/Partitions/codex-browser-app/GPUCache/data_3`
- `.config/Codex/Default/Partitions/codex-browser-app/GPUCache/index`
- `.config/Codex/Default/Partitions/codex-browser-app/History`
- `.config/Codex/Default/Partitions/codex-browser-app/History-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Storage/leveldb/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Storage/leveldb/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Storage/leveldb/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Storage/leveldb/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Local Storage/leveldb/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Login Data`
- `.config/Codex/Default/Partitions/codex-browser-app/Login Data For Account`
- `.config/Codex/Default/Partitions/codex-browser-app/Login Data For Account-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Login Data-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Network Persistent State`
- `.config/Codex/Default/Partitions/codex-browser-app/PersistentOriginTrials/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/PersistentOriginTrials/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/PersistentOriginTrials/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Platform Notifications/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Platform Notifications/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Platform Notifications/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Platform Notifications/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Platform Notifications/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Preferences`
- `.config/Codex/Default/Partitions/codex-browser-app/PreferredApps`
- `.config/Codex/Default/Partitions/codex-browser-app/README`
- `.config/Codex/Default/Partitions/codex-browser-app/Reporting and NEL`
- `.config/Codex/Default/Partitions/codex-browser-app/Reporting and NEL-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/SCT Auditing Pending Reports`
- `.config/Codex/Default/Partitions/codex-browser-app/Secure Preferences`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SegmentInfoDB/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SegmentInfoDB/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SegmentInfoDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SignalDB/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SignalDB/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SignalDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SignalStorageConfigDB/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SignalStorageConfigDB/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Segmentation Platform/SignalStorageConfigDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/ServerCertificate`
- `.config/Codex/Default/Partitions/codex-browser-app/ServerCertificate-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/Database/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/Database/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/Database/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/Database/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/Database/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/ScriptCache/4cb013792b196a35_0`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/ScriptCache/4cb013792b196a35_1`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/ScriptCache/index`
- `.config/Codex/Default/Partitions/codex-browser-app/Service Worker/ScriptCache/index-dir/the-real-index`
- `.config/Codex/Default/Partitions/codex-browser-app/Session Storage/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Session Storage/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Session Storage/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Session Storage/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Session Storage/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Sessions`
- `.config/Codex/Default/Partitions/codex-browser-app/Shared Dictionary/cache/index`
- `.config/Codex/Default/Partitions/codex-browser-app/Shared Dictionary/cache/index-dir/the-real-index`
- `.config/Codex/Default/Partitions/codex-browser-app/Shared Dictionary/db`
- `.config/Codex/Default/Partitions/codex-browser-app/Shared Dictionary/db-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Site Characteristics Database/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Site Characteristics Database/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Site Characteristics Database/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Site Characteristics Database/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Site Characteristics Database/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Sync Data/LevelDB/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/Sync Data/LevelDB/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/Sync Data/LevelDB/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/Sync Data/LevelDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/Sync Data/LevelDB/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/Top Sites`
- `.config/Codex/Default/Partitions/codex-browser-app/Top Sites-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Translate Ranker Model`
- `.config/Codex/Default/Partitions/codex-browser-app/TransportSecurity`
- `.config/Codex/Default/Partitions/codex-browser-app/Trust Tokens`
- `.config/Codex/Default/Partitions/codex-browser-app/Trust Tokens-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/Web Data`
- `.config/Codex/Default/Partitions/codex-browser-app/Web Data-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/WebStorage/QuotaManager`
- `.config/Codex/Default/Partitions/codex-browser-app/WebStorage/QuotaManager-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/blob_storage/6cb52aa0-654c-4769-8cde-6b62deb5e211`
- `.config/Codex/Default/Partitions/codex-browser-app/chrome_cart_db/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/chrome_cart_db/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/chrome_cart_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/commerce_subscription_db/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/commerce_subscription_db/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/commerce_subscription_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/declarative_performance_observer.db`
- `.config/Codex/Default/Partitions/codex-browser-app/declarative_performance_observer.db-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/discount_infos_db/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/discount_infos_db/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/discount_infos_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/discounts_db/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/discounts_db/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/discounts_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/heavy_ad_intervention_opt_out.db`
- `.config/Codex/Default/Partitions/codex-browser-app/heavy_ad_intervention_opt_out.db-journal`
- `.config/Codex/Default/Partitions/codex-browser-app/optimization_guide_hint_cache_store/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/optimization_guide_hint_cache_store/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/optimization_guide_hint_cache_store/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/parcel_tracking_db/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/parcel_tracking_db/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/parcel_tracking_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/metadata/CURRENT`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/metadata/LOCK`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/metadata/LOG`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/metadata/LOG.old`
- `.config/Codex/Default/Partitions/codex-browser-app/shared_proto_db/metadata/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/.org.chromium.Chromium.TransportSecurity.GzswJX`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Account Web Data`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Account Web Data-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Affiliation Database`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Affiliation Database-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/AutofillAiModelCache/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/AutofillAiModelCache/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/AutofillAiModelCache/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/AutofillStrikeDatabase/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/AutofillStrikeDatabase/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/AutofillStrikeDatabase/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/BookmarkMergedSurfaceOrdering`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/BudgetDatabase/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/BudgetDatabase/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/BudgetDatabase/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/ClientCertificates/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/ClientCertificates/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/ClientCertificates/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Cookies`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Cookies-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DIPS`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DIPS-wal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnGraphiteCache/data_0`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnGraphiteCache/data_1`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnGraphiteCache/data_2`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnGraphiteCache/data_3`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnGraphiteCache/index`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnWebGPUCache/data_0`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnWebGPUCache/data_1`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnWebGPUCache/data_2`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnWebGPUCache/data_3`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/DawnWebGPUCache/index`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Rules/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Rules/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Rules/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Rules/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Scripts/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Scripts/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Scripts/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension Scripts/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension State/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension State/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension State/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension State/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extension State/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/128.png`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/af/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/am/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ar/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/as/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/az/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/be/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bg/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bn/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ca/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cs/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cy/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/da/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/de/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/el/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_CA/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_GB/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_US/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es_419/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/et/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/eu/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fa/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fi/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fil/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr_CA/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gl/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gu/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hi/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hr/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hu/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hy/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/id/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/is/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/it/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/iw/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ja/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ka/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kk/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/km/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kn/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ko/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lo/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lt/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lv/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mk/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ml/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mn/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mr/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ms/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/my/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ne/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/nl/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/no/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/or/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pa/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pl/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_BR/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_PT/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ro/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ru/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/si/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sk/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sl/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sq/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sr/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sv/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sw/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ta/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/te/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/th/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/tr/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uk/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ur/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uz/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/vi/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_CN/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_HK/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_TW/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zu/messages.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/computed_hashes.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/verified_contents.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/dasherSettingSchema.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/manifest.json`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument.html`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument_main.js`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/page_embed_script.js`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/service_worker_bin_prod.js`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Favicons`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Favicons-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Feature Engagement Tracker/AvailabilityDB/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Feature Engagement Tracker/AvailabilityDB/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Feature Engagement Tracker/AvailabilityDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Feature Engagement Tracker/EventDB/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Feature Engagement Tracker/EventDB/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Feature Engagement Tracker/EventDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GCM Store/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GCM Store/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GCM Store/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GCM Store/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GCM Store/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GPUCache/data_0`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GPUCache/data_1`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GPUCache/data_2`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GPUCache/data_3`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/GPUCache/index`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/History`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/History-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Storage/leveldb/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Storage/leveldb/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Storage/leveldb/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Storage/leveldb/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Local Storage/leveldb/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Login Data`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Login Data For Account`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Login Data For Account-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Login Data-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Network Persistent State`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/PersistentOriginTrials/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/PersistentOriginTrials/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/PersistentOriginTrials/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Platform Notifications/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Platform Notifications/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Platform Notifications/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Platform Notifications/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Platform Notifications/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Preferences`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/PreferredApps`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/README`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Reporting and NEL`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Reporting and NEL-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/SCT Auditing Pending Reports`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Secure Preferences`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SegmentInfoDB/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SegmentInfoDB/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SegmentInfoDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SignalDB/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SignalDB/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SignalDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SignalStorageConfigDB/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SignalStorageConfigDB/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Segmentation Platform/SignalStorageConfigDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/ServerCertificate`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/ServerCertificate-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/Database/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/Database/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/Database/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/Database/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/Database/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/ScriptCache/4cb013792b196a35_0`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/ScriptCache/4cb013792b196a35_1`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/ScriptCache/index`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Service Worker/ScriptCache/index-dir/the-real-index`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Session Storage/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Session Storage/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Session Storage/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Session Storage/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Session Storage/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Shared Dictionary/cache/index`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Shared Dictionary/cache/index-dir/the-real-index`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Shared Dictionary/db`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Shared Dictionary/db-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Site Characteristics Database/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Site Characteristics Database/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Site Characteristics Database/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Site Characteristics Database/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Site Characteristics Database/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Sync Data/LevelDB/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Sync Data/LevelDB/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Sync Data/LevelDB/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Sync Data/LevelDB/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Sync Data/LevelDB/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Top Sites`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Top Sites-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Translate Ranker Model`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/TransportSecurity`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Trust Tokens`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Trust Tokens-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Web Data`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/Web Data-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/WebStorage/QuotaManager`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/WebStorage/QuotaManager-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/blob_storage/d8c3432a-2190-46ff-bf39-ac6364402c7f`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/chrome_cart_db/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/chrome_cart_db/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/chrome_cart_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/commerce_subscription_db/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/commerce_subscription_db/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/commerce_subscription_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/declarative_performance_observer.db`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/declarative_performance_observer.db-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/discount_infos_db/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/discount_infos_db/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/discount_infos_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/discounts_db/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/discounts_db/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/discounts_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/heavy_ad_intervention_opt_out.db`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/heavy_ad_intervention_opt_out.db-journal`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/optimization_guide_hint_cache_store/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/optimization_guide_hint_cache_store/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/optimization_guide_hint_cache_store/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/parcel_tracking_db/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/parcel_tracking_db/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/parcel_tracking_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/MANIFEST-000001`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/metadata/CURRENT`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/metadata/LOCK`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/metadata/LOG`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/metadata/LOG.old`
- `.config/Codex/Default/Partitions/codex-mcp-app-sandbox%3Ashared/shared_proto_db/metadata/MANIFEST-000001`
- `.config/Codex/Default/PersistentOriginTrials/LOCK`
- `.config/Codex/Default/PersistentOriginTrials/LOG`
- `.config/Codex/Default/PersistentOriginTrials/LOG.old`
- `.config/Codex/Default/Platform Notifications/CURRENT`
- `.config/Codex/Default/Platform Notifications/LOCK`
- `.config/Codex/Default/Platform Notifications/LOG`
- `.config/Codex/Default/Platform Notifications/LOG.old`
- `.config/Codex/Default/Platform Notifications/MANIFEST-000001`
- `.config/Codex/Default/Preferences`
- `.config/Codex/Default/PreferredApps`
- `.config/Codex/Default/README`
- `.config/Codex/Default/Reporting and NEL`
- `.config/Codex/Default/Reporting and NEL-journal`
- `.config/Codex/Default/SCT Auditing Pending Reports`
- `.config/Codex/Default/Secure Preferences`
- `.config/Codex/Default/Segmentation Platform/SegmentInfoDB/LOCK`
- `.config/Codex/Default/Segmentation Platform/SegmentInfoDB/LOG`
- `.config/Codex/Default/Segmentation Platform/SegmentInfoDB/LOG.old`
- `.config/Codex/Default/Segmentation Platform/SignalDB/LOCK`
- `.config/Codex/Default/Segmentation Platform/SignalDB/LOG`
- `.config/Codex/Default/Segmentation Platform/SignalDB/LOG.old`
- `.config/Codex/Default/Segmentation Platform/SignalStorageConfigDB/LOCK`
- `.config/Codex/Default/Segmentation Platform/SignalStorageConfigDB/LOG`
- `.config/Codex/Default/Segmentation Platform/SignalStorageConfigDB/LOG.old`
- `.config/Codex/Default/ServerCertificate`
- `.config/Codex/Default/ServerCertificate-journal`
- `.config/Codex/Default/Service Worker/Database/CURRENT`
- `.config/Codex/Default/Service Worker/Database/LOCK`
- `.config/Codex/Default/Service Worker/Database/LOG`
- `.config/Codex/Default/Service Worker/Database/LOG.old`
- `.config/Codex/Default/Service Worker/Database/MANIFEST-000001`
- `.config/Codex/Default/Service Worker/ScriptCache/4cb013792b196a35_0`
- `.config/Codex/Default/Service Worker/ScriptCache/4cb013792b196a35_1`
- `.config/Codex/Default/Service Worker/ScriptCache/index`
- `.config/Codex/Default/Service Worker/ScriptCache/index-dir/the-real-index`
- `.config/Codex/Default/Session Storage/CURRENT`
- `.config/Codex/Default/Session Storage/LOCK`
- `.config/Codex/Default/Session Storage/LOG`
- `.config/Codex/Default/Session Storage/LOG.old`
- `.config/Codex/Default/Session Storage/MANIFEST-000001`
- `.config/Codex/Default/Shared Dictionary/cache/index`
- `.config/Codex/Default/Shared Dictionary/cache/index-dir/the-real-index`
- `.config/Codex/Default/Shared Dictionary/db`
- `.config/Codex/Default/Shared Dictionary/db-journal`
- `.config/Codex/Default/Site Characteristics Database/CURRENT`
- `.config/Codex/Default/Site Characteristics Database/LOCK`
- `.config/Codex/Default/Site Characteristics Database/LOG`
- `.config/Codex/Default/Site Characteristics Database/LOG.old`
- `.config/Codex/Default/Site Characteristics Database/MANIFEST-000001`
- `.config/Codex/Default/Sync Data/LevelDB/CURRENT`
- `.config/Codex/Default/Sync Data/LevelDB/LOCK`
- `.config/Codex/Default/Sync Data/LevelDB/LOG`
- `.config/Codex/Default/Sync Data/LevelDB/LOG.old`
- `.config/Codex/Default/Sync Data/LevelDB/MANIFEST-000001`
- `.config/Codex/Default/Top Sites`
- `.config/Codex/Default/Top Sites-journal`
- `.config/Codex/Default/Translate Ranker Model`
- `.config/Codex/Default/TransportSecurity`
- `.config/Codex/Default/Trust Tokens`
- `.config/Codex/Default/Trust Tokens-journal`
- `.config/Codex/Default/Web Data`
- `.config/Codex/Default/Web Data-journal`
- `.config/Codex/Default/WebStorage/QuotaManager`
- `.config/Codex/Default/WebStorage/QuotaManager-journal`
- `.config/Codex/Default/blob_storage/cd1dea1f-49c7-404f-a8d5-657e184cc6db`
- `.config/Codex/Default/chrome_cart_db/LOCK`
- `.config/Codex/Default/chrome_cart_db/LOG`
- `.config/Codex/Default/chrome_cart_db/LOG.old`
- `.config/Codex/Default/commerce_subscription_db/LOCK`
- `.config/Codex/Default/commerce_subscription_db/LOG`
- `.config/Codex/Default/commerce_subscription_db/LOG.old`
- `.config/Codex/Default/declarative_performance_observer.db`
- `.config/Codex/Default/declarative_performance_observer.db-journal`
- `.config/Codex/Default/discount_infos_db/LOCK`
- `.config/Codex/Default/discount_infos_db/LOG`
- `.config/Codex/Default/discount_infos_db/LOG.old`
- `.config/Codex/Default/discounts_db/LOCK`
- `.config/Codex/Default/discounts_db/LOG`
- `.config/Codex/Default/discounts_db/LOG.old`
- `.config/Codex/Default/heavy_ad_intervention_opt_out.db`
- `.config/Codex/Default/heavy_ad_intervention_opt_out.db-journal`
- `.config/Codex/Default/optimization_guide_hint_cache_store/LOCK`
- `.config/Codex/Default/optimization_guide_hint_cache_store/LOG`
- `.config/Codex/Default/optimization_guide_hint_cache_store/LOG.old`
- `.config/Codex/Default/parcel_tracking_db/LOCK`
- `.config/Codex/Default/parcel_tracking_db/LOG`
- `.config/Codex/Default/parcel_tracking_db/LOG.old`
- `.config/Codex/Default/shared_proto_db/CURRENT`
- `.config/Codex/Default/shared_proto_db/LOCK`
- `.config/Codex/Default/shared_proto_db/LOG`
- `.config/Codex/Default/shared_proto_db/LOG.old`
- `.config/Codex/Default/shared_proto_db/MANIFEST-000001`
- `.config/Codex/Default/shared_proto_db/metadata/CURRENT`
- `.config/Codex/Default/shared_proto_db/metadata/LOCK`
- `.config/Codex/Default/shared_proto_db/metadata/LOG`
- `.config/Codex/Default/shared_proto_db/metadata/LOG.old`
- `.config/Codex/Default/shared_proto_db/metadata/MANIFEST-000001`
- `.config/Codex/Dictionaries/en-US-10-2.bdic`
- `.config/Codex/FileTypePolicies/145.0.7584.0/_metadata/verified_contents.json`
- `.config/Codex/FileTypePolicies/145.0.7584.0/download_file_types.pb`
- `.config/Codex/FileTypePolicies/145.0.7584.0/manifest.json`
- `.config/Codex/FirstPartySetsPreloaded/2025.7.24.0/LICENSE`
- `.config/Codex/FirstPartySetsPreloaded/2025.7.24.0/_metadata/verified_contents.json`
- `.config/Codex/FirstPartySetsPreloaded/2025.7.24.0/manifest.json`
- `.config/Codex/FirstPartySetsPreloaded/2025.7.24.0/sets.json`
- `.config/Codex/GPUPersistentCache/GPUCache/4YWEKYZOTOBTKKPZK4HJJEJ3KCN6ZLRS/cache.db`
- `.config/Codex/GPUPersistentCache/GPUCache/4YWEKYZOTOBTKKPZK4HJJEJ3KCN6ZLRS/cache.db-wal`
- `.config/Codex/Global Shortcuts Profile ID`
- `.config/Codex/Last Version`
- `.config/Codex/Local State`
- `.config/Codex/MEIPreload/1.1.0.3/_metadata/verified_contents.json`
- `.config/Codex/MEIPreload/1.1.0.3/manifest.json`
- `.config/Codex/MEIPreload/1.1.0.3/preloaded_data.pb`
- `.config/Codex/NativeMessagingHosts`
- `.config/Codex/OnDeviceHeadSuggestModel/20251024.824731831.14/_metadata/verified_contents.json`
- `.config/Codex/OnDeviceHeadSuggestModel/20251024.824731831.14/cr_en-us_500000_index.bin`
- `.config/Codex/OnDeviceHeadSuggestModel/20251024.824731831.14/manifest.json`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/_metadata/verified_contents.json`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/laya_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/manifest.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/manifest.json`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/prompt_gemma4_12b_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/prompt_gemma4_4b_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/prompt_gemma4_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/prompt_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/proofreader_small_expert_model_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/scam_detection_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/speech_recognition_small_expert_model_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/summarizer_gemma4_12b_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/summarizer_gemma4_4b_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/summarizer_gemma4_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/summarizer_nano_v3_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/summarizer_small_expert_model_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/writing_assistance_gemma4_12b_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/writing_assistance_gemma4_4b_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/writing_assistance_gemma4_solution_config.binarypb`
- `.config/Codex/OptimizationGuideModelsManifest/1.20261005.5/writing_assistance_solution_config.binarypb`
- `.config/Codex/OptimizationHints/757/_metadata/verified_contents.json`
- `.config/Codex/OptimizationHints/757/manifest.json`
- `.config/Codex/OptimizationHints/757/optimization-hints.pb`
- `.config/Codex/OriginTrials`
- `.config/Codex/PKIMetadata/1798/_metadata/verified_contents.json`
- `.config/Codex/PKIMetadata/1798/crs.pb`
- `.config/Codex/PKIMetadata/1798/ct_config.pb`
- `.config/Codex/PKIMetadata/1798/kp_pinslist.pb`
- `.config/Codex/PKIMetadata/1798/manifest.json`
- `.config/Codex/PKIMetadata/1798/mtc_config.pb`
- `.config/Codex/PrivacySandboxAttestationsPreloaded`
- `.config/Codex/SSLErrorAssistant/7/_metadata/verified_contents.json`
- `.config/Codex/SSLErrorAssistant/7/manifest.json`
- `.config/Codex/SSLErrorAssistant/7/ssl_error_assistant.pb`
- `.config/Codex/Safe Browsing`
- `.config/Codex/SafetyTips/3091/_metadata/verified_contents.json`
- `.config/Codex/SafetyTips/3091/manifest.json`
- `.config/Codex/SafetyTips/3091/safety_tips.pb`
- `.config/Codex/SingletonCookie`
- `.config/Codex/SingletonLock`
- `.config/Codex/SingletonSocket`
- `.config/Codex/Subresource Filter/Indexed Rules/38/9.72.0/Ruleset Data`
- `.config/Codex/Subresource Filter/Unindexed Rules/9.72.0/Filtering Rules`
- `.config/Codex/Subresource Filter/Unindexed Rules/9.72.0/LICENSE.txt`
- `.config/Codex/Subresource Filter/Unindexed Rules/9.72.0/_metadata/verified_contents.json`
- `.config/Codex/Subresource Filter/Unindexed Rules/9.72.0/manifest.json`
- `.config/Codex/TrustTokenKeyCommitments/2026.8.3.1/LICENSE`
- `.config/Codex/TrustTokenKeyCommitments/2026.8.3.1/_metadata/verified_contents.json`
- `.config/Codex/TrustTokenKeyCommitments/2026.8.3.1/keys.json`
- `.config/Codex/TrustTokenKeyCommitments/2026.8.3.1/manifest.json`
- `.config/Codex/WasmTtsEngine/20260917.1/_metadata/verified_contents.json`
- `.config/Codex/WasmTtsEngine/20260917.1/background_compiled.js`
- `.config/Codex/WasmTtsEngine/20260917.1/bindings_main.js`
- `.config/Codex/WasmTtsEngine/20260917.1/bindings_main.wasm`
- `.config/Codex/WasmTtsEngine/20260917.1/manifest.json`
- `.config/Codex/WasmTtsEngine/20260917.1/offscreen.html`
- `.config/Codex/WasmTtsEngine/20260917.1/offscreen_compiled.js`
- `.config/Codex/WasmTtsEngine/20260917.1/streaming_worklet_processor.js`
- `.config/Codex/WasmTtsEngine/20260917.1/voices.json`
- `.config/Codex/WasmTtsEngine/20260917.1/wasm_tts_manifest_v3.json`
- `.config/Codex/WidevineCdm/4.10.3112.0/LICENSE`
- `.config/Codex/WidevineCdm/4.10.3112.0/_metadata/verified_contents.json`
- `.config/Codex/WidevineCdm/4.10.3112.0/_platform_specific/linux_x64/libwidevinecdm.so`
- `.config/Codex/WidevineCdm/4.10.3112.0/manifest.json`
- `.config/Codex/WidevineCdm/latest-component-updated-widevine-cdm`
- `.config/Codex/ZxcvbnData/3/_metadata/verified_contents.json`
- `.config/Codex/ZxcvbnData/3/english_wikipedia.txt`
- `.config/Codex/ZxcvbnData/3/female_names.txt`
- `.config/Codex/ZxcvbnData/3/male_names.txt`
- `.config/Codex/ZxcvbnData/3/manifest.json`
- `.config/Codex/ZxcvbnData/3/passwords.txt`
- `.config/Codex/ZxcvbnData/3/ranked_dicts`
- `.config/Codex/ZxcvbnData/3/surnames.txt`
- `.config/Codex/ZxcvbnData/3/us_tv_and_film.txt`
- `.config/Codex/artifact-sessions/runtime-generations`
- `.config/Codex/browser-sidebar-page-states.json`
- `.config/Codex/codex-browser-app/Account Web Data`
- `.config/Codex/codex-browser-app/Account Web Data-journal`
- `.config/Codex/codex-browser-app/Affiliation Database`
- `.config/Codex/codex-browser-app/Affiliation Database-journal`
- `.config/Codex/codex-browser-app/AutofillAiModelCache/LOCK`
- `.config/Codex/codex-browser-app/AutofillAiModelCache/LOG`
- `.config/Codex/codex-browser-app/AutofillAiModelCache/LOG.old`
- `.config/Codex/codex-browser-app/AutofillStrikeDatabase/LOCK`
- `.config/Codex/codex-browser-app/AutofillStrikeDatabase/LOG`
- `.config/Codex/codex-browser-app/AutofillStrikeDatabase/LOG.old`
- `.config/Codex/codex-browser-app/BookmarkMergedSurfaceOrdering`
- `.config/Codex/codex-browser-app/BudgetDatabase/LOCK`
- `.config/Codex/codex-browser-app/BudgetDatabase/LOG`
- `.config/Codex/codex-browser-app/BudgetDatabase/LOG.old`
- `.config/Codex/codex-browser-app/ClientCertificates/LOCK`
- `.config/Codex/codex-browser-app/ClientCertificates/LOG`
- `.config/Codex/codex-browser-app/ClientCertificates/LOG.old`
- `.config/Codex/codex-browser-app/Cookies`
- `.config/Codex/codex-browser-app/Cookies-journal`
- `.config/Codex/codex-browser-app/DawnGraphiteCache/data_0`
- `.config/Codex/codex-browser-app/DawnGraphiteCache/data_1`
- `.config/Codex/codex-browser-app/DawnGraphiteCache/data_2`
- `.config/Codex/codex-browser-app/DawnGraphiteCache/data_3`
- `.config/Codex/codex-browser-app/DawnGraphiteCache/index`
- `.config/Codex/codex-browser-app/DawnWebGPUCache/data_0`
- `.config/Codex/codex-browser-app/DawnWebGPUCache/data_1`
- `.config/Codex/codex-browser-app/DawnWebGPUCache/data_2`
- `.config/Codex/codex-browser-app/DawnWebGPUCache/data_3`
- `.config/Codex/codex-browser-app/DawnWebGPUCache/index`
- `.config/Codex/codex-browser-app/Extension Rules/CURRENT`
- `.config/Codex/codex-browser-app/Extension Rules/LOCK`
- `.config/Codex/codex-browser-app/Extension Rules/LOG`
- `.config/Codex/codex-browser-app/Extension Rules/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Extension Scripts/CURRENT`
- `.config/Codex/codex-browser-app/Extension Scripts/LOCK`
- `.config/Codex/codex-browser-app/Extension Scripts/LOG`
- `.config/Codex/codex-browser-app/Extension Scripts/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Extension State/CURRENT`
- `.config/Codex/codex-browser-app/Extension State/LOCK`
- `.config/Codex/codex-browser-app/Extension State/LOG`
- `.config/Codex/codex-browser-app/Extension State/LOG.old`
- `.config/Codex/codex-browser-app/Extension State/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/128.png`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/af/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/am/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ar/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/as/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/az/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/be/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bg/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/bn/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ca/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cs/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/cy/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/da/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/de/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/el/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_CA/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_GB/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/en_US/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/es_419/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/et/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/eu/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fa/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fi/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fil/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/fr_CA/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gl/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/gu/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hi/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hr/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hu/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/hy/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/id/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/is/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/it/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/iw/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ja/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ka/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kk/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/km/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/kn/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ko/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lo/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lt/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/lv/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mk/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ml/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mn/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/mr/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ms/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/my/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ne/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/nl/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/no/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/or/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pa/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pl/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_BR/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/pt_PT/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ro/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ru/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/si/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sk/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sl/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sq/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sr/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sv/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/sw/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ta/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/te/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/th/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/tr/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uk/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/ur/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/uz/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/vi/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_CN/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_HK/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zh_TW/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_locales/zu/messages.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/computed_hashes.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/_metadata/verified_contents.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/dasherSettingSchema.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/manifest.json`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument.html`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/offscreendocument_main.js`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/page_embed_script.js`
- `.config/Codex/codex-browser-app/Extensions/ghbmnnjooekpmoecnnnilnnbdlolhkhi/1.110.1_0/service_worker_bin_prod.js`
- `.config/Codex/codex-browser-app/Favicons`
- `.config/Codex/codex-browser-app/Favicons-journal`
- `.config/Codex/codex-browser-app/Feature Engagement Tracker/AvailabilityDB/LOCK`
- `.config/Codex/codex-browser-app/Feature Engagement Tracker/AvailabilityDB/LOG`
- `.config/Codex/codex-browser-app/Feature Engagement Tracker/AvailabilityDB/LOG.old`
- `.config/Codex/codex-browser-app/Feature Engagement Tracker/EventDB/LOCK`
- `.config/Codex/codex-browser-app/Feature Engagement Tracker/EventDB/LOG`
- `.config/Codex/codex-browser-app/Feature Engagement Tracker/EventDB/LOG.old`
- `.config/Codex/codex-browser-app/GCM Store/CURRENT`
- `.config/Codex/codex-browser-app/GCM Store/LOCK`
- `.config/Codex/codex-browser-app/GCM Store/LOG`
- `.config/Codex/codex-browser-app/GCM Store/LOG.old`
- `.config/Codex/codex-browser-app/GCM Store/MANIFEST-000001`
- `.config/Codex/codex-browser-app/GPUCache/data_0`
- `.config/Codex/codex-browser-app/GPUCache/data_1`
- `.config/Codex/codex-browser-app/GPUCache/data_2`
- `.config/Codex/codex-browser-app/GPUCache/data_3`
- `.config/Codex/codex-browser-app/GPUCache/index`
- `.config/Codex/codex-browser-app/History`
- `.config/Codex/codex-browser-app/History-journal`
- `.config/Codex/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/CURRENT`
- `.config/Codex/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOCK`
- `.config/Codex/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG`
- `.config/Codex/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/LOG.old`
- `.config/Codex/codex-browser-app/Local Extension Settings/ghbmnnjooekpmoecnnnilnnbdlolhkhi/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Local Storage/leveldb/CURRENT`
- `.config/Codex/codex-browser-app/Local Storage/leveldb/LOCK`
- `.config/Codex/codex-browser-app/Local Storage/leveldb/LOG`
- `.config/Codex/codex-browser-app/Local Storage/leveldb/LOG.old`
- `.config/Codex/codex-browser-app/Local Storage/leveldb/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Login Data`
- `.config/Codex/codex-browser-app/Login Data For Account`
- `.config/Codex/codex-browser-app/Login Data For Account-journal`
- `.config/Codex/codex-browser-app/Login Data-journal`
- `.config/Codex/codex-browser-app/Network Persistent State`
- `.config/Codex/codex-browser-app/PersistentOriginTrials/LOCK`
- `.config/Codex/codex-browser-app/PersistentOriginTrials/LOG`
- `.config/Codex/codex-browser-app/PersistentOriginTrials/LOG.old`
- `.config/Codex/codex-browser-app/Platform Notifications/CURRENT`
- `.config/Codex/codex-browser-app/Platform Notifications/LOCK`
- `.config/Codex/codex-browser-app/Platform Notifications/LOG`
- `.config/Codex/codex-browser-app/Platform Notifications/LOG.old`
- `.config/Codex/codex-browser-app/Platform Notifications/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Preferences`
- `.config/Codex/codex-browser-app/PreferredApps`
- `.config/Codex/codex-browser-app/README`
- `.config/Codex/codex-browser-app/Reporting and NEL`
- `.config/Codex/codex-browser-app/Reporting and NEL-journal`
- `.config/Codex/codex-browser-app/SCT Auditing Pending Reports`
- `.config/Codex/codex-browser-app/Secure Preferences`
- `.config/Codex/codex-browser-app/Segmentation Platform/SegmentInfoDB/LOCK`
- `.config/Codex/codex-browser-app/Segmentation Platform/SegmentInfoDB/LOG`
- `.config/Codex/codex-browser-app/Segmentation Platform/SegmentInfoDB/LOG.old`
- `.config/Codex/codex-browser-app/Segmentation Platform/SignalDB/LOCK`
- `.config/Codex/codex-browser-app/Segmentation Platform/SignalDB/LOG`
- `.config/Codex/codex-browser-app/Segmentation Platform/SignalDB/LOG.old`
- `.config/Codex/codex-browser-app/Segmentation Platform/SignalStorageConfigDB/LOCK`
- `.config/Codex/codex-browser-app/Segmentation Platform/SignalStorageConfigDB/LOG`
- `.config/Codex/codex-browser-app/Segmentation Platform/SignalStorageConfigDB/LOG.old`
- `.config/Codex/codex-browser-app/ServerCertificate`
- `.config/Codex/codex-browser-app/ServerCertificate-journal`
- `.config/Codex/codex-browser-app/Service Worker/Database/CURRENT`
- `.config/Codex/codex-browser-app/Service Worker/Database/LOCK`
- `.config/Codex/codex-browser-app/Service Worker/Database/LOG`
- `.config/Codex/codex-browser-app/Service Worker/Database/LOG.old`
- `.config/Codex/codex-browser-app/Service Worker/Database/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Service Worker/ScriptCache/4cb013792b196a35_0`
- `.config/Codex/codex-browser-app/Service Worker/ScriptCache/4cb013792b196a35_1`
- `.config/Codex/codex-browser-app/Service Worker/ScriptCache/index`
- `.config/Codex/codex-browser-app/Service Worker/ScriptCache/index-dir/the-real-index`
- `.config/Codex/codex-browser-app/Shared Dictionary/cache/index`
- `.config/Codex/codex-browser-app/Shared Dictionary/cache/index-dir/the-real-index`
- `.config/Codex/codex-browser-app/Shared Dictionary/db`
- `.config/Codex/codex-browser-app/Shared Dictionary/db-journal`
- `.config/Codex/codex-browser-app/Site Characteristics Database/CURRENT`
- `.config/Codex/codex-browser-app/Site Characteristics Database/LOCK`
- `.config/Codex/codex-browser-app/Site Characteristics Database/LOG`
- `.config/Codex/codex-browser-app/Site Characteristics Database/LOG.old`
- `.config/Codex/codex-browser-app/Site Characteristics Database/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Sync Data/LevelDB/CURRENT`
- `.config/Codex/codex-browser-app/Sync Data/LevelDB/LOCK`
- `.config/Codex/codex-browser-app/Sync Data/LevelDB/LOG`
- `.config/Codex/codex-browser-app/Sync Data/LevelDB/LOG.old`
- `.config/Codex/codex-browser-app/Sync Data/LevelDB/MANIFEST-000001`
- `.config/Codex/codex-browser-app/Top Sites`
- `.config/Codex/codex-browser-app/Top Sites-journal`
- `.config/Codex/codex-browser-app/TransportSecurity`
- `.config/Codex/codex-browser-app/Trust Tokens`
- `.config/Codex/codex-browser-app/Trust Tokens-journal`
- `.config/Codex/codex-browser-app/Web Data`
- `.config/Codex/codex-browser-app/Web Data-journal`
- `.config/Codex/codex-browser-app/WebStorage/QuotaManager`
- `.config/Codex/codex-browser-app/WebStorage/QuotaManager-journal`
- `.config/Codex/codex-browser-app/blob_storage/54fdfb31-5b6d-424e-b967-bbc055848bff`
- `.config/Codex/codex-browser-app/chrome_cart_db/LOCK`
- `.config/Codex/codex-browser-app/chrome_cart_db/LOG`
- `.config/Codex/codex-browser-app/chrome_cart_db/LOG.old`
- `.config/Codex/codex-browser-app/commerce_subscription_db/LOCK`
- `.config/Codex/codex-browser-app/commerce_subscription_db/LOG`
- `.config/Codex/codex-browser-app/commerce_subscription_db/LOG.old`
- `.config/Codex/codex-browser-app/declarative_performance_observer.db`
- `.config/Codex/codex-browser-app/declarative_performance_observer.db-journal`
- `.config/Codex/codex-browser-app/discount_infos_db/LOCK`
- `.config/Codex/codex-browser-app/discount_infos_db/LOG`
- `.config/Codex/codex-browser-app/discount_infos_db/LOG.old`
- `.config/Codex/codex-browser-app/discounts_db/LOCK`
- `.config/Codex/codex-browser-app/discounts_db/LOG`
- `.config/Codex/codex-browser-app/discounts_db/LOG.old`
- `.config/Codex/codex-browser-app/heavy_ad_intervention_opt_out.db`
- `.config/Codex/codex-browser-app/heavy_ad_intervention_opt_out.db-journal`
- `.config/Codex/codex-browser-app/optimization_guide_hint_cache_store/LOCK`
- `.config/Codex/codex-browser-app/optimization_guide_hint_cache_store/LOG`
- `.config/Codex/codex-browser-app/optimization_guide_hint_cache_store/LOG.old`
- `.config/Codex/codex-browser-app/parcel_tracking_db/LOCK`
- `.config/Codex/codex-browser-app/parcel_tracking_db/LOG`
- `.config/Codex/codex-browser-app/parcel_tracking_db/LOG.old`
- `.config/Codex/codex-browser-app/shared_proto_db/CURRENT`
- `.config/Codex/codex-browser-app/shared_proto_db/LOCK`
- `.config/Codex/codex-browser-app/shared_proto_db/LOG`
- `.config/Codex/codex-browser-app/shared_proto_db/LOG.old`
- `.config/Codex/codex-browser-app/shared_proto_db/MANIFEST-000001`
- `.config/Codex/codex-browser-app/shared_proto_db/metadata/CURRENT`
- `.config/Codex/codex-browser-app/shared_proto_db/metadata/LOCK`
- `.config/Codex/codex-browser-app/shared_proto_db/metadata/LOG`
- `.config/Codex/codex-browser-app/shared_proto_db/metadata/LOG.old`
- `.config/Codex/codex-browser-app/shared_proto_db/metadata/MANIFEST-000001`
- `.config/Codex/component_crx_cache/1bf1f200dcccd461b2d029d000d0fcf800f0571c932db31467b9d5d301e0a98f`
- `.config/Codex/component_crx_cache/23759e3f6d0119a00038b963cec9fb7abafd7b65a35a7e83c7697511db59e6e7`
- `.config/Codex/component_crx_cache/2c2b171cd00f7446bfb4834e94b9fb96cf106dcb3318dc49c4ff63c3088337f7`
- `.config/Codex/component_crx_cache/34ce4871804d747cf5cdafaec2f4befe25ff7333137f72394b0ff5a4e60f6160`
- `.config/Codex/component_crx_cache/3eb16d6c28b502ac4cfee8f4a148df05f4d93229fa36a71db8b08d06329ff18a`
- `.config/Codex/component_crx_cache/501827b4f9f4db80529433eabf520c2dc66be589a9ae2dff1a8b8e76d0dea2c7`
- `.config/Codex/component_crx_cache/545666a4efd056351597bb386aea1368105ededc976ed5650d8682daab9f37ff`
- `.config/Codex/component_crx_cache/56c21927faa028be6ce18c931660eec37e41da4bfbfd47cafa48350f828c0dbd`
- `.config/Codex/component_crx_cache/608de406394ea7501102b9d3df7def2f2a58ef27b1d534de66a32d38c250637d`
- `.config/Codex/component_crx_cache/76f59779450d5b031d4fe6204f6dc322ad38c745297f84db8f1769c0e8e03c85`
- `.config/Codex/component_crx_cache/7b05c14dba04ed522210b733f004cb0e74d7679a653b19bd029f9bc0e6b19903`
- `.config/Codex/component_crx_cache/970a3e1af7f986ad66e212796dcd4a2db1210f7222cdfaa7d59d491fbe0369af`
- `.config/Codex/component_crx_cache/9bec6c2c0185d3305ac8495047a1aa01e725d58f8f18d219742a2988f07cd93a`
- `.config/Codex/component_crx_cache/abd93867c038d4d17c101ace2226d7e21303d984d7097271392bae6be478495b`
- `.config/Codex/component_crx_cache/ae216724654f3e52d3c502328caf83f773e66cc5818c38850165864005a35169`
- `.config/Codex/component_crx_cache/ae38058ef6659ce0b8058d3b8f7542f635910015fe40ccfc1e98d2464c383f32`
- `.config/Codex/component_crx_cache/b757d679b1173611222409a39569e79132c2563a811fdef613885a21ae4abd48`
- `.config/Codex/component_crx_cache/c1d06372335775cfd1512f62e8a0464d08f5058a6a622904f2357fb2c3aa6b09`
- `.config/Codex/component_crx_cache/c52c62a7c50daf7d3f73ec16977cd4b0ea401710807d5dbe3850941dd1b73a70`
- `.config/Codex/component_crx_cache/metadata.json`
- `.config/Codex/executor-plugins/codex-app-tools/.codex-plugin/plugin.json`
- `.config/Codex/executor-plugins/codex-app-tools/.mcp.json`
- `.config/Codex/executor-plugins/codex-app-tools/scripts/launch_codex_app_tools_mcp`
- `.config/Codex/executor-plugins/codex-app-tools/scripts/launch_codex_app_tools_mcp.cmd`
- `.config/Codex/executor-plugins/codex-app-tools/server.mjs`
- `.config/Codex/extensions_crx_cache/metadata.json`
- `.config/Codex/first_party_sets.db`
- `.config/Codex/first_party_sets.db-journal`
- `.config/Codex/hyphen-data/120.0.6050.0/_metadata/verified_contents.json`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-af.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-as.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-be.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-bg.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-bn.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-cs.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-cu.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-cy.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-da.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-de-1901.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-de-1996.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-de-ch-1901.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-el.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-en-gb.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-en-us.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-es.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-et.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-eu.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-fr.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-ga.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-gl.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-gu.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-hi.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-hr.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-hu.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-hy.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-it.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-ka.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-kn.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-la.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-lt.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-lv.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-ml.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-mn-cyrl.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-mr.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-mul-ethi.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-nb.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-nl.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-nn.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-or.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-pa.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-pt.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-ru.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-sk.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-sl.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-sq.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-sv.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-ta.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-te.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-tk.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-uk.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/hyph-und-ethi.hyb`
- `.config/Codex/hyphen-data/120.0.6050.0/manifest.json`
- `.config/Codex/segmentation_platform/ukm_db`
- `.config/Codex/segmentation_platform/ukm_db-wal`
- `.config/Codex/sentry/queue/queue-v2.json`
- `.config/Codex/sentry/scope_v3.json`
- `.config/Codex/statsig-state.json`
- `.config/Codex/storage-cache/38d1ef4f441ca472113c060c1876a81ee00e4f1eaea35e47d4445ef18b3f14b5.json`
- `.config/hypr/scripts/screenshot_region.sh`
- `.config/opencode/themes/opencode-wallpaper.json`
- `.local/bin/desktop-control-start`
- `.local/bin/desktop-input`

## Normalized symlink targets

None.

## Directory permissions

These directories have custom permission modes that chezmoi cannot encode
in source attributes. Their original modes are saved separately in
`system/user/directory-permissions.json`. The audit checks them against
the live folders; mismatches appear under Separate snapshot checks.
`chezmoi status` may still show permission differences for these paths.

| Directory | Original mode |
| --- | --- |
| `.config/gh` | `0751` |
| `.config/inkscape` | `0751` |
| `.config/inkscape/extensions` | `0751` |
| `.config/inkscape/fontcollections` | `0751` |
| `.config/inkscape/icons` | `0751` |
| `.config/inkscape/keys` | `0751` |
| `.config/inkscape/paint` | `0751` |
| `.config/inkscape/palettes` | `0751` |
| `.config/inkscape/symbols` | `0751` |
| `.config/inkscape/templates` | `0751` |
| `.config/inkscape/themes` | `0751` |
| `.config/inkscape/ui` | `0751` |

After applying on another machine, restore them with:

```sh
python3 scripts/restore-config-permissions.py
```

## Separate snapshot checks

- Selected browser preferences differ; refresh with python3 scripts/user_settings.py

## Run again

```sh
python3 scripts/audit-configs.py --report docs/reports/config-coverage.md
```

A new file that is neither tracked nor explicitly excluded makes the audit fail.
The audit does not scan all personal documents, installed programs, or system
files under `/etc` and `/usr`; those are outside these home-config roots.
