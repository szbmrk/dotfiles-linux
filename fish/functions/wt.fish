function wt --description 'Open a git worktree for <branch> [base] in the current tmux session'
    if test (count $argv) -lt 1 -o (count $argv) -gt 2
        echo "usage: wt <branch> [base]"
        return 1
    end

    if not set -q TMUX
        echo "wt: run inside tmux"
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
        if git show-ref --verify --quiet refs/heads/$branch
            git worktree add $dir $branch
        else if git show-ref --verify --quiet refs/remotes/origin/$branch
            git worktree add $dir --track -b $branch origin/$branch
        else
            git worktree add $dir -b $branch $base
        end
        or return 1

        for env_file in $root/.env*
            cp $env_file $dir/
        end
    end

    cd $dir
    tmux rename-window server

    for spec in 'nvim:nvim .' 'lg:lazygit' 'cc:claude'
        set parts (string split -m1 : -- $spec)
        set window (tmux new-window -d -P -F '#{window_id}' -n $parts[1] -c $dir)
        tmux send-keys -t $window $parts[2] Enter
    end
end
