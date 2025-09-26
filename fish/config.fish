# ===========================
# Environment variables
# ===========================
set -Ux STARSHIP_CONFIG $HOME/.config/starship/starship.toml
set -Ux STARSHIP_CACHE /tmp
set -Ux PROJECTS_DIR $HOME/Projects
set -Ux XDG_CONFIG_HOME $HOME/.config
set PATH $PATH /home/szobo/.local/bin

alias c="clear"
alias claer="clear"
alias vim="nvim"

# ===========================
# Functions
# ===========================
function home
    clear
    cd $HOME
    fastfetch
end

function config
    cd $HOME/.config
end

function downloads
    cd $HOME/Downloads
end

function projects
    cd $PROJECTS_DIR
end

function dotfiles_push
    cd $HOME/.config
    git add .
    git commit -m "."
    git push
end

function gitp
    git add .
    git commit -m "."
    git push
end

# ===========================
# Starship Prompt
# ===========================
starship init fish | source
