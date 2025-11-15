# XDG BASE DIRECTORIES
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x XDG_CACHE_HOME "$HOME/.cache"
set -x XDG_DATA_HOME "$HOME/.local/share"
set -x XDG_STATE_HOME "$HOME/.local/state"

# HOME CLEANING
set -x CALCHISTFILE "$XDG_CACHE_HOME/calc_history"
set -x CARGO_HOME "$XDG_CONFIG_HOME/cargo"
set -x DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"
set -x DOTNET_CLI_HOME "$XDG_DATA_HOME/dotnet"
set -x GHCUP_USE_XDG_DIRS true
set -x GNUPGHOME "$XDG_CONFIG_HOME/gnupg"
set -x GOPATH "$HOME/Personal/Programming/go"
set -x GRADLE_USER_HOME "$XDG_DATA_HOME/gradle"
set -x GTK2_RC_FILES "$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
set -x HISTFILE "$XDG_STATE_HOME/bash/history"
set -x LESSHISTFILE "$XDG_CONFIG_HOME/less/history"
set -x LESSKEY "$XDG_CONFIG_HOME/less/keys"
set -x NODE_REPL_HISTORY "$XDG_DATA_HOME/node_repl_history"
set -x NPM_CONFIG_CACHE "$XDG_CACHE_HOME/npm"
set -x NPM_CONFIG_PREFIX "$XDG_CONFIG_HOME/npm"
set -x NPM_CONFIG_USERCONFIG "$NPM_CONFIG_PREFIX/npmrc"
set -x NUGET_PACKAGES "$XDG_CACHE_HOME/NuGetPackages"
set -x PARALLEL_HOME "$XDG_CONFIG_HOME/parallel"
set -x PYTHONPYCACHEPREFIX "$XDG_CACHE_HOME/python"
set -x PYTHONUSERBASE "$XDG_DATA_HOME/python"
set -x PYTHON_HISTORY "$XDG_STATE_HOME/python/history"
set -x RANDFILE "$XDG_DATA_HOME/randfile"
set -x RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -x SCREENRC "$XDG_CONFIG_HOME/screen/screenrc"
set -x SCREENDIR "$XDG_RUNTIME_DIR/screen"
set -x STACK_XDG 1
set -x W3M_DIR "$XDG_DATA_HOME/w3m"
set -x WGETRC "$XDG_CONFIG_HOME/wgetrc"
set -x WINEPREFIX "$XDG_DATA_HOME/wine"
alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"
alias wget="wget --hsts-file='$XDG_DATA_HOME/wget-hsts'"

# SET PATH
for pa in \
    "$XDG_CONFIG_HOME/cabal/bin" \
    "$XDG_CONFIG_HOME/cargo/bin" \
    "$HOME/.local/bin"

    contains $pa $PATH || set -x PATH "$pa" "$PATH"
end

# INPUT METHOD
set -x QT_IM_MODULE fcitx5
set -x SDL_IM_MODULE fcitx5
set -x XMODIFIERS '@im=fcitx5'

# SET EDITOR
for ed in \
    helix hx \
    nvim vim vi

    command -vq "$ed" && set -x EDITOR "$ed" && break
end

# Util Variables
set notification "$HOME/Personal/Music/sounds/martlet-bell.wav"
set alert_image "$HOME/Personal/Pictures/renders/SuperSaiyanMartletSmol.gif"

# ALIASES >:3
command -vq helix && alias hx='helix'
command -vq hx && alias helix='hx'
alias bg-sysup="sysup -cypa $notification -i $alert_image"
alias whats-my-motherfucking-name='whoami'
# overrides
alias rereflect="rereflect -a $notification -i $alert_image"
# kittens
alias icat='kitty +kitten icat'

# ZOXIDE
zoxide init --cmd cd fish | source

# START
set -x fish_greeting
if test (tty) = /dev/tty1
    Hyprland # Start automatically in default terminal
else if status is-interactive
    # STARTING STARSHIP
    starship init fish | source
    enable_transience
    function starship_transient_prompt_func
        starship module character
    end

    # GREETING
    if command -vq souls.sh
        souls.sh -t darklynx m | awk '
            BEGIN { print "" }
            { print "  " $0 }
            END { print "" }'
    else if command -vq neofetch
        echo
        neofetch | neofetch | grep --color=never -oxE '^.+$'
    end
end
