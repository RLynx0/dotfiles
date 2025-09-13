#!/bin/bash

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
                                                                    

TERMINAL="${TERMINAL:-"kitty"}"
HEIGHT="${HEIGHT:-"100%"}"
WIDTH="${WIDTH:-"40%"}"
DOCK="${DOCK:-"ur"}"
FORCE_FOCUS=''

function show_help {
  echo "Usage: $(basename $0) [OPTIONS] [COMMAND]"
  printf "\nArguments:\n"
  echo "  [COMMAND]  Command to execute in the terminal."
  printf "\nOptions:\n"
  echo "  -H <HEIGHT>     Height of the window. Either N pixels or P% percentage.        Default: 100%"
  echo "  -W <WIDTH>      Width of the window. Either N pixels or P% percentage.         Default: 40%"
  echo "  -c <CMD_CLASS>  Window class name used to identify the terminal.               Default: quick-<COMMAND>-cmd"
  echo "  -w <WORKSPACE>  Name of the special workspace the terminal will be opened in.  Default: quick-<COMMAND>-cmd"
  echo "  -t <TERMINAL>   Use a specific terminal.                                       Default: kitty"
  echo "  -d <DOCK>       List of characters used to dock the terminal.                  Default: ur"
  echo "  -f              Force focusing the window, even if it's already focused."
  echo "  -r              Restore previous HEIGHT, WIDTH and DOCK."
  echo "  -h              Print this help message and exit."
}

while getopts "H:W:c:w:t:d:frh" arg; do
    case $arg in
    H) HEIGHT="$OPTARG" ;;
    W) WIDTH="$OPTARG" ;;
    c) CMD_CLASS="$OPTARG" ;;
    w) WORKSPACE="$OPTARG" ;;
    t) TERMINAL="$OPTARG" ;;
    d) DOCK="$OPTARG" ;;
    f) FORCE_FOCUS='1' ;;
    h) show_help; exit ;;
    *)
      echo "Use the -h flag for usage." >&2
      exit 1
    esac
done
shift $(($OPTIND-1))

CTX_FILE="/tmp/quick-$1-cmd.ctx.tmp"
SET_FILE="/tmp/quick-$1-cmd.set.tmp"
CMD_CLASS="${CMD_CLASS:-"quick-$1-cmd"}"
WORKSPACE="${WORKSPACE:-"quick-$1-cmd"}"

function check_command {
  command -v "$1" &>/dev/null || {
    echo "ERROR: Required program '$1' not found in PATH"
    exit 1
  }
}

[ -z "$1" ] || check_command "$1"
check_command "$TERMINAL"
check_command hyprctl

BORDER="$(hyprctl getoption general:border_size | head -1 | awk '{ print $2 }')"
GAPS=($(hyprctl getoption general:gaps_out | head -1 | awk -F ': ' '{ print $2 }'))
GAP_T="${GAPS[0]}"; GAP_R="${GAPS[1]}";
GAP_B="${GAPS[2]}"; GAP_L="${GAPS[3]}";
OFF_Y="$(echo "($GAP_T - $GAP_B) / 2" | bc)"

function pos {
  hyprctl activewindow \
  | awk '/^\s*at:/ { print $2 }' \
  | tr "," " ";
}

function probe_reserved {
  hyprctl dispatch centerwindow 0 > /dev/null; p0=($(pos))
  hyprctl dispatch centerwindow 1 > /dev/null; p1=($(pos))
  x0="${p0[0]}"; y0="${p0[1]}"; x1="${p1[0]}"; y1="${p1[1]}"
  ox="$(echo "2 * ($x1 - $x0 + $BORDER) + $GAP_L + $GAP_R" | bc)"
  oy="$(echo "2 * ($y1 - $y0 + $BORDER) + $GAP_T + $GAP_B" | bc)"
  echo "-$ox -$oy"
}

function unchanged {
  p="$(cat "$CTX_FILE")"
  g="$(echo ${GAPS[@]} | tr " " ",")"
  c="$(hyprctl monitors \
  | awk -v c="$WIDTH $HEIGHT $DOCK $g" '
    /^Monitor/ { m = $2 }
    /^\s*scale:/ { s = $2 }
    /^\s*focused: yes/ { print m,s,c }
  ' | tee "$CTX_FILE")"
  [ "$c" == "$p" ]
}

function already_open {
  hyprctl clients | grep "class: $CMD_CLASS" > /dev/null
}

function focused {
  hyprctl activewindow | grep "class: $CMD_CLASS" > /dev/null
}

function in_ws {
  hyprctl activewindow \
  | grep -E "^\s*workspace:.+special:$WORKSPACE" > /dev/null
}

function save_setup {
  hyprctl activewindow | awk '
    /^\s*size:/ { print "resizeactive -- \"exact "$2"\"" }
    /^\s*at:/ { print "moveactive -- \"exact "$2"\"" }
  ' | tr ',' ' ' | awk '{ print "hyprctl dispatch "$0 }
  ' > "$SET_FILE";
}

function open_cmd {
  hyprctl keyword windowrulev2 "float, class:$CMD_CLASS"
  "$TERMINAL" --class "$CMD_CLASS" "$1" &
  while true; do already_open && break; sleep 0.05; done
}

function toggle_view {
  in_ws && hyprctl dispatch togglespecialworkspace "$WORKSPACE" \
  || hyprctl dispatch focuswindow "class:$CMD_CLASS"
}

function dock {
  hyprctl dispatch movewindow "$1"
  case "$1" in
    u|t) hyprctl dispatch moveactive -- "0 $GAP_T"  ;;
    d|b) hyprctl dispatch moveactive -- "0 -$GAP_B" ;;
    l)   hyprctl dispatch moveactive -- "$GAP_L 0"  ;;
    r)   hyprctl dispatch moveactive -- "-$GAP_R 0" ;;
  esac
}

function setup {
  in_ws || hyprctl dispatch movetoworkspace "special:$WORKSPACE"
  unchanged && sh "$SET_FILE" && return
  hyprctl dispatch setfloating
  hyprctl dispatch resizeactive "exact $WIDTH $HEIGHT"
  hyprctl dispatch resizeactive -- "$(probe_reserved)"
  hyprctl dispatch centerwindow 1
  hyprctl dispatch moveactive -- "0 $OFF_Y"
  while read -n1 d; do case "$d" in
    u|t|d|b|l|r) dock "$d" ;;
  esac; done <<< "$DOCK"
  save_setup
}

already_open || open_cmd "$1"                   > /dev/null
focused && [ -n "$FORCE_FOCUS" ] || toggle_view > /dev/null
focused && setup                                > /dev/null
exit 0
