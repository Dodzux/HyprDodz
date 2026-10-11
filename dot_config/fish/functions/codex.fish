function codex --wraps "$HOME/.local/bin/codex" --description 'Run Codex with wallpaper-synced terminal colors'
    # Scope the app title to this foreground invocation; Fish restores its
    # normal prompt title afterwards. No remote-control access is needed.
    set -l codex_title_active 0
    if status is-interactive; and set -q KITTY_WINDOW_ID; and isatty stdout
        set codex_title_active 1
        printf '\e[22;0t\e]2;Codex\a'
    end

    if test -x "$HOME/.local/bin/codex-accent"; and test -x "$HOME/.local/bin/codex"
        command "$HOME/.local/bin/codex-accent" "$HOME/.local/bin/codex" $argv
    else
        command codex $argv
    end
    set -l codex_exit_status $status
    if test $codex_title_active -eq 1
        printf '\e[23;0t'
    end
    return $codex_exit_status
end
