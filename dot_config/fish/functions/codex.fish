function codex --wraps "$HOME/.local/bin/codex" --description 'Run Codex with wallpaper-synced terminal colors'
    if test -x "$HOME/.local/bin/codex-accent"; and test -x "$HOME/.local/bin/codex"
        command "$HOME/.local/bin/codex-accent" "$HOME/.local/bin/codex" $argv
    else
        command codex $argv
    end
end
