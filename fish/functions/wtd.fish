function wtd --description 'Remove the worktree for [branch] (default: current one) and its local branch'
    if test (count $argv) -gt 1
        echo "usage: wtd [branch]"
        return 1
    end

    set branch $argv[1]
    if test -z "$branch"
        set branch (git branch --show-current 2>/dev/null)
    end

    set paths (__wt_paths $branch)
    or begin
        echo "wtd: not inside a git repo"
        return 1
    end
    set root $paths[1]
    set dir $paths[2]

    if not test -d $dir
        echo "wtd: no worktree at $dir"
        return 1
    end

    if test -n "$(git -C $dir status --porcelain)"
        echo "wtd: $dir has uncommitted changes"
        return 1
    end

    if set -q TMUX
        tmux set-window-option automatic-rename on
    end

    cd $root
    git worktree remove $dir
    or return 1
    git branch -D $branch
    git fetch --prune --quiet
end
