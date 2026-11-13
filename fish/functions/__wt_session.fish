function __wt_session --description 'Print the tmux session name for a checkout <dir>'
    string replace -ar '[.:]' '_' -- (basename $argv[1])
end
