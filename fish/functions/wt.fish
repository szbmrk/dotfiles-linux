function wt --description 'Open an Alacritty window on a tmux session for the git worktree of <branch> [base]'
    if test (count $argv) -lt 1 -o (count $argv) -gt 2
        echo "usage: wt <branch> [base]"
        return 1
    end

    set branch $argv[1]
    set base $argv[2]
    set paths (__wt_paths $branch)
    or begin
        echo "wt: not inside a git repo"
        return 1
    end
    set root $paths[1]
    set dir $paths[2]

    if not test -d $dir
        git fetch --quiet origin 2>/dev/null

        if git show-ref --verify --quiet refs/heads/$branch
            git worktree add $dir $branch
        else if git show-ref --verify --quiet refs/remotes/origin/$branch
            git worktree add $dir --track -b $branch origin/$branch
        else
            test -n "$base"
            or set base (git -C $root rev-parse --abbrev-ref --verify --quiet '@{upstream}' 2>/dev/null)
            git worktree add $dir --no-track -b $branch $base
        end
        or return 1

        for file in (git -C $root ls-files --others -- '.env*' .claude/settings.local.json)
            mkdir -p (dirname $dir/$file)
            cp $root/$file $dir/$file
        end

        if test -f $dir/pnpm-lock.yaml
            pnpm -C $dir install
        end
    end

    set session (__wt_session $dir)

    if not tmux has-session -t "=$session" 2>/dev/null
        tmux new-session -d -s $session -n server -c $dir
        # The global `off` would move this window onto another session when wtd kills this one.
        tmux set-option -t "=$session" detach-on-destroy on

        for spec in 'nvim:nvim .' 'claude:claude' 'lazygit:lazygit'
            set parts (string split -m1 : -- $spec)
            set window (tmux new-window -d -P -F '#{window_id}' -t "=$session:" -n $parts[1] -c $dir)
            tmux send-keys -t $window $parts[2] Enter
        end
    end

    if count (tmux list-clients -t "=$session") >/dev/null
        echo "wt: $session is already open"
        return
    end

    # tmux refuses to attach while TMUX is inherited from the calling pane.
    setsid -f env -u TMUX -u TMUX_PANE alacritty -T $session -e tmux attach-session -t "=$session" >/dev/null 2>&1
end
