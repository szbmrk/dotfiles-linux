function wtd --description 'Remove the current worktree, its local branch and its tmux session'
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

    if test -n "$branch"; and test "$(git for-each-ref --format='%(upstream:track)' refs/heads/$branch)" != '[gone]'
        set unpushed (git rev-list --count $branch --not --remotes)
        if test $unpushed -gt 0
            read -l -P "wtd: $branch has $unpushed commits on no remote. Delete anyway? [y/N] " answer
            or return 1
            string match -qi y -- $answer
            or return 1
        end
    end

    set session (__wt_session $dir)
    set -q TMUX
    and set current (tmux display-message -p '#S')

    if test "$current" = $session
        tmux kill-window -a
    else
        tmux kill-session -t "=$session" 2>/dev/null
    end

    cd $root
    git worktree remove $dir
    or return 1
    if test -n "$branch"
        git branch -D $branch
    end
    git fetch --prune --quiet

    if test "$current" = $session
        tmux kill-session -t "=$session"
    end
end
