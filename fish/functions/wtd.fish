function wtd --description 'Remove the current worktree and its local branch'
    set dir (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "wtd: not inside a git repo"
        return 1
    end
    set root (dirname (git rev-parse --path-format=absolute --git-common-dir))
    set branch (git branch --show-current)

    if test $dir = $root
        echo "wtd: $dir is the main checkout, not a worktree"
        return 1
    end

    if test -n "$(git status --porcelain)"
        echo "wtd: $dir has uncommitted changes"
        return 1
    end

    if set -q TMUX
        set current (tmux display-message -p '#{window_id}')
        for line in (tmux list-panes -s -F '#{window_id} #{pane_current_path}')
            set parts (string split -m1 ' ' -- $line)
            test $parts[1] = $current; and continue
            if string match -q -- "$dir" $parts[2]; or string match -q -- "$dir/*" $parts[2]
                tmux kill-window -t $parts[1] 2>/dev/null
            end
        end
        tmux set-window-option automatic-rename on
    end

    cd $root
    git worktree remove $dir
    or return 1
    if test -n "$branch"
        git branch -D $branch
    end
    git fetch --prune --quiet
end
