# ===========================
# Environment variables
# ===========================
set -Ux STARSHIP_CONFIG $HOME/.config/starship/starship.toml
set -Ux STARSHIP_CACHE /tmp
set -Ux PROJECTS_DIR $HOME/Projects
set -Ux XDG_CONFIG_HOME $HOME/.config
set -Ux fish_greeting ""
set -Ux JAVA_HOME /usr/lib/jvm/java-21-temurin-jdk
set -Ux PNPM_HOME ~/.local/share/pnpm
set -Ux ANI_CLI_PLAYER vlc
set -Ux LIBGL_ALWAYS_SOFTWARE 1
set -Ux ANDROID_HOME $HOME/Android/Sdk
set -Ux ANDROID_SDK_ROOT $HOME/Android/Sdk
set -Ux CAPACITOR_ANDROID_STUDIO_PATH /opt/android-studio/bin/studio.sh
set -Ux MANGOHUD 1
# set -Ux PORTLESS_STATE_DIR /home/szobo/.portless

set PATH $PATH /home/szobo/.local/bin
set PATH $PATH /home/szobo/.cargo/bin
set PATH $PATH /home/szobo/.dotnet/tools
set PATH $PATH /home/szobo/go/bin
set PATH $PATH /home/szobo/kotlin/kotlinc/bin
set PATH $PATH /home/szobo/kotlin-lsp/bin
set PATH $PATH /home/szobo/.fly/bin
set PATH $PATH /usr/lib/jvm/java-21-temurin-jdk/bin
set PATH $PATH /home/szobo/Android/Sdk/platform-tools
set PATH $PATH $JAVA_HOME
set PATH $PATH $PNPM_HOME

alias c="clear"
alias claer="clear"
alias vim="nvim"
alias cat="bat"

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

function edit_config
    cd $HOME/.config
    nvim .
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
# Make template projects
# ===========================
function make_c_proj
    set -l projname (read -P "Project name: ")
    if test -z "$projname"
        echo "No project name given!"
        return 1
    end

    set -l target "$HOME/Projects/$projname"

    if test -e "$target"
        echo "Error: $target already exists."
        return 1
    end

    cp -r "$HOME/templates/c" "$target"
    mkdir "$target/include/$projname"
    echo "Created new C project at $target"

    set -l makefile_path "$target/Makefile"

    if test -f "$makefile_path"
        sed -i "1iPROJECT_NAME = $projname" "$makefile_path"
        echo "Updated Makefile with project name."
    else
        echo "Warning: Makefile not found at '$makefile_path'. Skipping modification."
    end
    cd "$target"
end

function make_cpp_proj
    set -l projname (read -P "Project name: ")
    if test -z "$projname"
        echo "No project name given!"
        return 1
    end

    set -l target "$HOME/Projects/$projname"

    if test -e "$target"
        echo "Error: $target already exists."
        return 1
    end

    cp -r "$HOME/templates/cpp" "$target"
    mkdir "$target/include/$projname"
    echo "Created new C++ project at $target"

    set -l makefile_path "$target/Makefile"

    if test -f "$makefile_path"
        sed -i "1iPROJECT_NAME = $projname" "$makefile_path"
        echo "Updated Makefile with project name."
    else
        echo "Warning: Makefile not found at '$makefile_path'. Skipping modification."
    end
    cd "$target"
end

function make_python_proj
    set -l projname (read -P "Project name: ")
    if test -z "$projname"
        echo "No project name given!"
        return 1
    end

    set -l target "$HOME/Projects/$projname"

    if test -e "$target"
        echo "Error: $target already exists."
        return 1
    end

    cp -r "$HOME/templates/python" "$target"
    echo "Created new python project at $target"

    cd "$target"

    uv venv .venv
    source ".venv/bin/activate.fish"
end

function make_java_proj
    set -l projname (read -P "Project name: ")
    if test -z "$projname"
        echo "No project name given!"
        return 1
    end

    set -l target "$HOME/Projects/$projname"

    if test -e "$target"
        echo "Error: $target already exists."
        return 1
    end

    cp -r "$HOME/templates/java" "$target"
    echo "Created new java project at $target"

    cd "$target"
end

function make_rust_proj
    set -l projname (read -P "Project name: ")
    if test -z "$projname"
        echo "No project name given!"
        return 1
    end

    set -l target "$HOME/Projects/$projname"

    if test -e "$target"
        echo "Error: $target already exists."
        return 1
    end

    cp -r "$HOME/templates/rust" "$target"
    echo "Created new rust project at $target"

    set -l makefile_path "$target/Makefile"

    if test -f "$makefile_path"
        sed -i "1iPROJECT_NAME = $projname" "$makefile_path"
        echo "Updated Makefile with project name."
    else
        echo "Warning: Makefile not found at '$makefile_path'. Skipping modification."
    end

    set -l cargotoml_path "$target/Cargo.toml"

    if test -f "$cargotoml_path"
        sed -i "2iname = \"$projname\"" "$cargotoml_path"
        echo "Updated Cargo.toml with project name."
    else
        echo "Warning: Cargo.toml not found at '$cargotoml_path'. Skipping modification."
    end
    cd "$target"
end

eval "$(zoxide init fish --cmd cd)"
starship init fish | source

# opencode
fish_add_path /home/szobo/.opencode/bin

if status is-interactive
    and not set -q TMUX
    and test "$TERM_PROGRAM" != "vscode"

    set base main
    set session $base
    set i 2

    while tmux has-session -t "$session" 2>/dev/null
        set session "$base$i"
        set i (math $i + 1)
    end

    exec tmux new-session -s "$session" "tmux set-option -t '$session' destroy-unattached on; exec fish"
end

function tn
    set name (basename "$PWD")
    if set -q TMUX
        tmux new-session -d -s "$name" -c "$PWD" 2>/dev/null
        tmux switch-client -t "$name"
    else
        tmux new-session -A -s "$name" -c "$PWD"
    end
end
