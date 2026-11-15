# Approved terminal style, loaded after the existing prompt/tool initialization.
if not status is-interactive
    return
end

set -g fish_color_normal d6dce5
set -g fish_color_command 86c8f2
set -g fish_color_param d6dce5
set -g fish_color_quote 9bc9ad
set -g fish_color_redirection b6a5d9
set -g fish_color_end b6a5d9
set -g fish_color_error df8290
set -g fish_color_comment 697485
set -g fish_color_operator 90caca
set -g fish_color_escape dfbd94
set -g fish_color_autosuggestion 606878
set -g fish_color_search_match --background=263747
set -g fish_color_selection --background=263747
set -g fish_pager_color_prefix 86c8f2 --bold
set -g fish_pager_color_completion d6dce5
set -g fish_pager_color_description 697485
set -g fish_pager_color_selected_background --background=263747

function fish_prompt
    set -l previous_status $status
    printf '\n'
    set_color blue
    printf '󰉋  '
    set_color normal
    printf '%s' (prompt_pwd --dir-length=2)
    set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -n "$branch"
        set_color brblack
        printf '   '
        set_color magenta
        printf ' %s' "$branch"
    end
    printf '\n'
    if test $previous_status -eq 0
        set_color blue
    else
        set_color red
    end
    printf '❯ '
    set_color normal
end

function fish_right_prompt
    if test "$CMD_DURATION" -ge 1000 2>/dev/null
        set_color brblack
        printf '%ss' (math --scale=1 "$CMD_DURATION / 1000")
        set_color normal
    end
end

function fish_greeting
    printf '\n'
    set_color blue
    printf '    '
    set_color --bold normal
    printf 'HyprDodz'
    set_color normal
    set_color brblack
    printf '  /  terminal\n\n  '
    for color in blue cyan magenta green yellow red
        set_color $color
        printf '●  '
    end
    set_color normal
    printf '\n'
end
