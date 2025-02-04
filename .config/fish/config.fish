# XDG BASE DIRECTORIES
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# HOME CLEANING
export CALCHISTFILE="$XDG_CACHE_HOME/calc_history"
export CARGO_HOME="$XDG_CONFIG_HOME/cargo"
export GHCUP_USE_XDG_DIRS="true"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export LESSHISTFILE="$XDG_CONFIG_HOME/less/history"
export LESSKEY="$XDG_CONFIG_HOME/less/keys"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$XDG_CONFIG_HOME/npm"
export NPM_CONFIG_USERCONFIG="$NPM_CONFIG_PREFIX/npmrc"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
export SCREENDIR="$XDG_RUNTIME_DIR/screen"
export STACK_XDG=1
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export WINEPREFIX="$XDG_DATA_HOME/wine"

# SETTING PATH
set -a PAs "$XDG_CONFIG_HOME/cabal/bin"
set -a PAs "$XDG_CONFIG_HOME/cargo/bin"
set -a PAs "$HOME/bin"

for pa in $PAs
    if not string match -q $pa $PATH
        set PATH "$pa:$PATH"
    end
end

set -e PAs

# INPUT METHOD
set -x QT_IM_MODULE fcitx5
set -x SDL_IM_MODULE fcitx5
set -x XMODIFIERS "@im=fcitx5"

# SYS VARS
set EDITOR helix

# Util Variables
set terminal_pid (awk '{print $4}' /proc/(echo %self)/stat)
set terminal (basename "/"(ps -fp $terminal_pid | awk 'END {print $8}'))
set notification "$HOME/Personal/Music/sounds/martlet-bell.wav"

# ALIASES >:3
alias hx='helix'
alias netflix='qtwebflix'
alias bg-sysup="yes '' | sysup -ca $notification -i $HOME/Personal/Pictures/renders/SuperSaiyanMartletSmol.gif | tee"
alias rank-cmd='history | awk \'/^\w/{print $1}\' | sort | uniq -c | sort -rn'
alias whats-my-motherfucking-name="whoami"
# overrides
alias rereflect="rereflect -a $notification -i $HOME/Personal/Pictures/renders/SuperSaiyanMartletSmol.gif"
# kittens
alias icat='kitty +kitten icat'
# open url
alias corel='librewolf https://app.corelvector.com/'
alias duolingo='librewolf https://www.duolingo.com'
alias instagram='librewolf https://www.instagram.com'
alias twitch='librewolf https://www.twitch.tv'
alias whatsapp='librewolf https://web.whatsapp.com'
alias youtube='librewolf https://www.youtube.com'

# FUNCTIONS
function rep
    set command "$(history --null | fzf --read0)"
    test -z "$command" && return 130
    echo "$command" | awk -v c=">" '
    { print c, $0 }
    { c = " " }
    l > m { m = l }
    END { printf "\n" }'
    eval "$command"
end

# ZOXIDE
zoxide init --cmd cd fish | source

# START
set -x fish_greeting
if test (tty) = /dev/tty1
    Hyprland # Start automatically in default terminal
else if tty | grep -vE "^/dev/tty[0-9]" >/dev/null
    # STRATING STARSHIP
    function starship_transient_prompt_func
        starship module character
    end
    starship init fish | source
    enable_transience

    # GREETING
    if command -v souls.sh >/dev/null
        echo
        printf "  %s\n" (souls.sh m)
        echo
    else if command -v neofetch >/dev/null
        echo
        neofetch | neofetch | grep --color=never -oxE '^.+$'
    end
end
