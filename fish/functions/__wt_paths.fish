function __wt_paths --description 'Print main repo root and worktree dir for <branch>'
    set common_dir (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or return 1

    set root (dirname $common_dir)
    echo $root
    echo (dirname $root)/(basename $root)-(string replace -ar '[/.:]' '-' -- $argv[1])
end
