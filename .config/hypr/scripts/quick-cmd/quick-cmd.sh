#!/usr/bin/env bash

#  ██████╗ ██╗   ██╗██╗ ██████╗██╗  ██╗     ██████╗███╗   ███╗██████╗  #
# ██╔═══██╗██║   ██║██║██╔════╝██║ ██╔╝    ██╔════╝████╗ ████║██╔══██╗ #
# ██║   ██║██║   ██║██║██║     █████╔╝     ██║     ██╔████╔██║██║  ██║ #
# ██║▄▄ ██║██║   ██║██║██║     ██╔═██╗     ██║     ██║╚██╔╝██║██║  ██║ #
# ╚██████╔╝╚██████╔╝██║╚██████╗██║  ██╗    ╚██████╗██║ ╚═╝ ██║██████╔╝ #
#  ╚══▀▀═╝  ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝╚═╝     ╚═╝╚═════╝  #
#                 ___        ___ _                  __                 #
#                | _ )_  _  | _ \ |  _  _ _ _ __ __/  \                #
#                | _ \ || | |   / |_| || | ' \\ \ / () |               #
#                |___/\_, | |_|_\____\_, |_||_/_\_\\__/                #
#                     |__/           |__/                              #


set -uo pipefail

readonly LUA_SCRIPT_PATH="$(dirname "$0")/quick-cmd.lua"
readonly DEFAULT_HEIGHT='100%'
readonly DEFAULT_WIDTH='40%'
readonly DEFAULT_DOCK='ur'

TERMINAL="${TERMINAL:-"kitty"}"
HEIGHT="${HEIGHT:-"$DEFAULT_HEIGHT"}"
WIDTH="${WIDTH:-"$DEFAULT_WIDTH"}"
DOCK="${DOCK:-"$DEFAULT_DOCK"}"
C_IND_H=0; C_IND_W=0; C_IND_D=0
CLEAN_RESTORE='false'; FORCE_FOCUS=''

function show_help {
  echo "Open, toggle and position a terminal window in a special hyprland workspace."
  printf "\nUsage: $(basename "$0") [OPTIONS] [COMMAND]\n"
  printf "\nArguments:\n"
  echo "  [COMMAND]  Command to execute in the terminal."
  printf "\nOptions:\n"
  echo "  -H <HEIGHT>     Height of the window. Either N pixels or P% percentage.        Default: $DEFAULT_HEIGHT"
  echo "  -W <WIDTH>      Width of the window. Either N pixels or P% percentage.         Default: $DEFAULT_WIDTH"
  echo "  -d <DOCK>       List of characters used to dock the terminal.                  Default: $DEFAULT_DOCK"
  echo "  -c <CMD_CLASS>  Window class name used to identify the terminal.               Default: quick-<COMMAND>-<TERMINAL>"
  echo "  -w <WORKSPACE>  Name of the special workspace the terminal will be opened in.  Default: quick-<COMMAND>-<TERMINAL>"
  echo "  -t <TERMINAL>   Use a specific terminal.                                       Default: kitty"
  echo "  -f              Force focusing the window, even if it's already focused."
  echo "  -r              Restore previous HEIGHT, WIDTH and DOCK."
  echo "  -h              Print this help message and exit."
  printf "\nNotes:\n"
  echo "  HEIGHT, WIDTH and DOCK support special syntax."
  echo "  Setting their value to '$' will restore the previously used value."
  echo "  If this is not found, the value will fall back to its respective default."
  echo "  You can also pass these options multiple values delimited with ','."
  echo "  The script will cycle through these values on each execution."
  echo "  Finally, '-' is a shorthand for the default value."
  echo "  This may be useful when using the cycle feature."
}

while getopts "H:W:d:c:w:t:frh" arg; do
    case $arg in
    H) HEIGHT="$(tr -d ' ' <<<"$OPTARG")" ;;
    W) WIDTH="$(tr -d ' ' <<<"$OPTARG")" ;;
    d) DOCK="$(tr -d ' ' <<<"$OPTARG")" ;;
    c) CMD_CLASS="$OPTARG" ;;
    w) WORKSPACE="$OPTARG" ;;
    t) TERMINAL="$OPTARG" ;;
    f) FORCE_FOCUS='1' ;;
    r) HEIGHT='$'; WIDTH='$'; DOCK='$'; CLEAN_RESTORE='true' ;;
    h) show_help; exit ;;
    *)
      echo "Use the -h flag for usage." >&2
      exit 1
    esac
done
shift $(($OPTIND-1))

CMD_PROGRAM="${1:-""}"
CACHE_DIR="${XDG_CACHE_HOME:-"$HOME/.cache"}/quick-cmd"
CTX_FILE="$CACHE_DIR/quick-$CMD_PROGRAM-$TERMINAL.ctx"
CMD_CLASS="${CMD_CLASS:-"quick-$CMD_PROGRAM-$TERMINAL"}"
WORKSPACE="${WORKSPACE:-"quick-$CMD_PROGRAM-$TERMINAL"}"

function check_command {
  command -v "$1" &>/dev/null || {
    echo "ERROR: Required program '$1' not found in PATH" >&2
    exit 1
  }
}

[ -z "$CMD_PROGRAM" ] || check_command "$CMD_PROGRAM"
check_command "$TERMINAL"
check_command hyprctl

[ -f "$LUA_SCRIPT_PATH" ] || {
  echo "ERROR: Lua Script not found at $LUA_SCRIPT_PATH" >&2
  exit 1
}

# Loads variables LAST_DOCK, LAST_WIDTH, ...
source "$CTX_FILE" 2> /dev/null

function setup {
  # Set all required variables
  # Then include lua script from file
  hyprctl repl "
    WORKSPACE            = '${WORKSPACE:-""}'
    DEFAULT_DOCK         = '${DEFAULT_DOCK:-""}'
    DEFAULT_WIDTH        = '${DEFAULT_WIDTH:-""}'
    DEFAULT_HEIGHT       = '${DEFAULT_HEIGHT:-""}'
    DOCK                 = '${DOCK:-""}'
    WIDTH                = '${WIDTH:-""}'
    HEIGHT               = '${HEIGHT:-""}'
    LAST_DOCK            = '${LAST_DOCK:-""}'
    LAST_WIDTH           = '${LAST_WIDTH:-""}'
    LAST_HEIGHT          = '${LAST_HEIGHT:-""}'
    LAST_RESOLVED_DOCK   = '${LAST_RESOLVED_DOCK:-""}'
    LAST_RESOLVED_WIDTH  = '${LAST_RESOLVED_WIDTH:-""}'
    LAST_RESOLVED_HEIGHT = '${LAST_RESOLVED_HEIGHT:-""}'
    LAST_DOCK_INDEX      = '${LAST_DOCK_INDEX:-""}'
    LAST_WIDTH_INDEX     = '${LAST_WIDTH_INDEX:-""}'
    LAST_HEIGHT_INDEX    = '${LAST_HEIGHT_INDEX:-""}'
    CLEAN_RESTORE        = ${CLEAN_RESTORE:-"false"}
  " \
  "$(cat "$LUA_SCRIPT_PATH")" \
  | tee /dev/stderr > "$CTX_FILE"
}

function already_open {
  hyprctl repl 'for _, w in pairs(hl.get_windows()) do print(w.class) end' \
  | grep -E "^$CMD_CLASS$"
}

function focused {
  test "$(hyprctl repl 'hl.get_active_window().class')" = "$CMD_CLASS"
}

function in_ws {
  test "$(hyprctl repl 'hl.get_active_window().workspace.name')" = "special:$WORKSPACE"
}

function open_cmd {
  hyprctl eval 'hl.window_rule({ name = "float-'"$CMD_CLASS"'", match = { class = "'"$CMD_CLASS"'" }, float = true })'
  "$TERMINAL" --class "$CMD_CLASS" "$CMD_PROGRAM" &
  while true; do already_open && break; sleep 0.05; done
}

function toggle_view {
  in_ws && hyprctl dispatch 'hl.dsp.workspace.toggle_special("'"$WORKSPACE"'")' \
  || hyprctl dispatch 'hl.dsp.focus({ window = "class:'"$CMD_CLASS"'" })'
}

already_open || open_cmd                        > /dev/null
focused && [ -n "$FORCE_FOCUS" ] || toggle_view > /dev/null
focused && setup                                > /dev/null
exit 0
