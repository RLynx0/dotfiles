# Setting PATH
set -a PAs "$HOME/.config/cabal/bin"
set -a PAs "$HOME/.config/cargo/bin"
set -a PAs "$HOME/bin"

for pa in $PAs
    if not string match -q $pa $PATH
        set PATH "$pa:$PATH"
    end
end

set -e PAs


# Home Cleaning
export CALCHISTFILE="$HOME/.cache/calc_history"
export CARGO_HOME="$HOME/.config/cargo"
export GHCUP_USE_XDG_DIRS=true
export HISTFILE=".local/state/bash/history"
# export _JAVA_OPTIONS="-Djava.util.prefs.userRoot $HOME/.config/java"
export NODE_REPL_HISTORY="$HOME/.local/share/node_repl_history"
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/npmrc"
export PARALLEL_HOME="$HOME/.config/parallel"
export PYTHON_HISTORY="$HOME/.local/state/python/history"
export PYTHONPYCACHEPREFIX="$HOME/.cache/python"
export PYTHONUSERBASE="$HOME/.local/share/python"
export RUSTUP_HOME="$HOME/.local/share/rustup"
export STACK_XDG=1
export WGETRC="$HOME/.config/wgetrc"

# Sys Vars
set EDITOR helix

# Util Variables
set terminal_pid (awk '{print $4}' /proc/(echo %self)/stat)
set terminal (basename "/"(ps -fp $terminal_pid | awk 'END {print $8}'))
set notification "$HOME/Personal/Music/sounds/martlet-bell.wav"


# Aliases >:3
alias .git="git --work-tree $HOME --git-dir $HOME/.dotfiles"
alias .modified=".git status --porcelain | awk -F '^ *M +' '\$2{print \$2}'"
alias hx='helix'
alias netflix='qtwebflix'
alias bg-sysup="yes '' | sysup -ca $notification -i $HOME/Personal/Pictures/renders/SuperSaiyanMartletSmol.gif | tee"
alias rank-cmd='history | awk \'/^\w/{print $1}\' | sort | uniq -c | sort -rn'
alias whats-my-motherfucking-name="whoami"
alias !! 'set x (history | awk \'!/!!/\' | head -1); echo "> $x"; eval "$x"'
# Overrides
alias rereflect="rereflect -a $notification -i $HOME/Personal/Pictures/renders/SuperSaiyanMartletSmol.gif"
# Kittens
alias icat='kitty +kitten icat'
# Open URL
alias corel='librewolf https://app.corelvector.com/'
alias duolingo='librewolf https://www.duolingo.com'
alias instagram='librewolf https://www.instagram.com'
alias twitch='librewolf https://www.twitch.tv'
alias whatsapp='librewolf https://web.whatsapp.com'
alias youtube='librewolf https://www.youtube.com'

set -x fish_greeting
if test (tty) = /dev/tty1
    Hyprland
else
    # Strating Starship
    function starship_transient_prompt_func
        starship module character
    end
    starship init fish | source
    enable_transience

    # Greeting
    if command -v souls.sh >/dev/null
        echo
        printf "  %s\n" (souls.sh m)
        echo
    else if command -v neofetch >/dev/null
        echo
        neofetch | neofetch | grep --color=never -oxE '^.+$'
    end
end
