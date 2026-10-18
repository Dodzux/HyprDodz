function y --description 'Open Yazi in Home by default and follow its exit directory'
    # Track the exit directory so the calling shell can follow it.
    set state_dir ~/.local/state/yazi
    set state_file $state_dir/last-dir
    mkdir -p $state_dir

    # Explicit paths take precedence; otherwise always start in Home.
    set start_args $argv
    if test (count $argv) -eq 0
        set start_args "$HOME"
    end

    # Run yazi, writing the exit-cwd into the persistent state file
    command yazi $start_args --cwd-file="$state_file"

    # cd the shell to wherever yazi exited
    if test -s "$state_file"
        read -l cwd < "$state_file"
        if [ "$cwd" != "$PWD" ]; and test -d "$cwd"
            builtin cd -- "$cwd"
            if type -q zoxide
                zoxide add "$cwd"
            end
        end
    end
end
