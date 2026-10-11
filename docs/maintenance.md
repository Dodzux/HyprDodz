# Updating your configs

Run repository commands from `~/.local/share/chezmoi`. Chezmoi's source files
are the saved version; files in your home folder are the running version.

## Check what changed

```bash
chezmoi status
chezmoi diff --exclude=scripts
git status --short
```

`chezmoi diff` compares saved configs with the live files. `git diff` shows
changes made inside the source repository.

## Save a change from the running desktop

For an already managed file without a template:

```bash
chezmoi re-add ~/.config/hypr/modules/keybindings.lua
```

To sync all modified non-template files, use `chezmoi re-add`. To track a new
file, use `chezmoi add ~/.config/newapp/config`.

Templates need source edits: `re-add` deliberately skips them. For example:

```bash
chezmoi edit ~/.config/kitty/kitty.conf
```

Keep expressions such as `{{ template "accent" . }}` so wallpaper colors still
work. Preview with `chezmoi diff` before applying. To deploy a reviewed individual
config, use `chezmoi apply --interactive ~/.config/kitty/kitty.conf`.

## Commit and push

```bash
cd ~/.local/share/chezmoi
git diff --check
git diff
# Stage only the files you reviewed:
git add dot_config/hypr/modules/keybindings.lua
git diff --cached --stat
git commit -m "Update desktop shortcuts"
git push
```

Avoid applying the whole repo over newer live edits before saving them.

## Optional coverage audit

```bash
python3 scripts/audit-configs.py --report docs/reports/config-coverage.md
```

This compares the rendered configs with live files and lists unmanaged entries.
It exits with a failure status when it finds differences, unexplained files or
snapshot issues. Read those results before deciding what should be tracked;
account data and caches belong outside the repo.

Custom directory modes may appear in `chezmoi status` even when the supplemental
snapshot matches. Preview their restoration with:

```bash
python3 scripts/restore-config-permissions.py --dry-run
```

## Refresh the preview

Close all windows, then press `Super + Print`. [scripts/showcase.sh](../scripts/showcase.sh)
captures the focused monitor, commits the preview image and pushes it to GitHub.

[Back to the guides](README.md)
