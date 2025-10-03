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
                                                                    

DEFAULT_HEIGHT='100%'
DEFAULT_WIDTH='40%'
DEFAULT_DOCK='ur'

TERMINAL="${TERMINAL:-"kitty"}"
HEIGHT="${HEIGHT:-"$DEFAULT_HEIGHT"}"
WIDTH="${WIDTH:-"$DEFAULT_WIDTH"}"
DOCK="${DOCK:-"$DEFAULT_DOCK"}"
C_IND_H=0; C_IND_W=0; C_IND_D=0
CLEAN_RESTORE=''; FORCE_FOCUS=''

function show_help {
  echo "Open, toggle and position a terminal window in a special hyprland workspace."
  printf "\nUsage: $(basename $0) [OPTIONS] [COMMAND]\n"
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
    r) HEIGHT='$'; WIDTH='$'; DOCK='$'; CLEAN_RESTORE='1' ;;
    h) show_help; exit ;;
    *)
      echo "Use the -h flag for usage." >&2
      exit 1
    esac
done
shift $(($OPTIND-1))

CACHE_DIR="${XDG_CACHE_HOME:-"$HOME/.cache"}/quick-cmd"
CTX_FILE="$CACHE_DIR/quick-$1-$TERMINAL.ctx"
SET_FILE="$CACHE_DIR/quick-$1-$TERMINAL.set"
CMD_CLASS="${CMD_CLASS:-"quick-$1-$TERMINAL"}"
WORKSPACE="${WORKSPACE:-"quick-$1-$TERMINAL"}"
LITERAL_H="$HEIGHT"
LITERAL_W="$WIDTH"
LITERAL_D="$DOCK"

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
OFF_Y="$(((GAP_T - GAP_B) / 2))"

function pos {
  hyprctl activewindow \
  | awk '/^\s*at:/ { print $2 }' \
  | tr "," " ";
}

function probe_reserved {
  hyprctl dispatch centerwindow 0 > /dev/null; p0=($(pos))
  hyprctl dispatch centerwindow 1 > /dev/null; p1=($(pos))
  x0="${p0[0]}"; y0="${p0[1]}"; x1="${p1[0]}"; y1="${p1[1]}"
  ox="$((2 * (x1 - x0 + BORDER) + GAP_L + GAP_R))"
  oy="$((2 * (y1 - y0 + BORDER) + GAP_T + GAP_B))"
  echo "-$ox -$oy"
}

function resolve_val {
  local target="$1"
  local default="$2"
  local index=0
  local -a values
  IFS=',' read -ra values <<< "$target"
  local n_vals="${#values[@]}"
  local last_val="${3:-"$default"}"
  local last_index="${4:-"$n_vals"}"
  local last_literal="$5"
  [ "$target" == "$last_literal" ] \
  && index="$(((last_index + 1) % n_vals))"
  target="${values["$index"]}"
  [ "$target" == '-' ] && target="$default"
  [ "$target" == '$' ] && target="$last_val"
  echo "$target $index"
}

function resolve_hwd {
  set $(awk '{ print $3,$4,$5,$7,$8,$9,$10,$11,$12 }' "$CTX_FILE" 2> /dev/null)
  local h="$1";  local w="$2";  local d="$3"
  local ih="$4"; local iw="$5"; local id="$6"
  local lh="$7"; local lw="$8"; local ld="$9"
  set $(resolve_val "$HEIGHT" "$DEFAULT_HEIGHT" "$h" "$ih" "$lh"); HEIGHT="$1"; C_IND_H="$2"
  set $(resolve_val "$WIDTH"  "$DEFAULT_WIDTH"  "$w" "$iw" "$lw"); WIDTH="$1";  C_IND_W="$2"
  set $(resolve_val "$DOCK"   "$DEFAULT_DOCK"   "$d" "$id" "$ld"); DOCK="$1";   C_IND_D="$2"
  if [ -n "$CLEAN_RESTORE" ]; then
  C_IND_D="${id:-0}"; LITERAL_H="${lh:-"$HEIGHT"}"
  C_IND_H="${ih:-0}"; LITERAL_W="${lw:-"$WIDTH"}"
  C_IND_W="${iw:-0}"; LITERAL_D="${ld:-"$DOCK"}"
  fi
}

function unchanged {
  local p="$(awk '{ print $1,$2,$3,$4,$5,$6 }' "$CTX_FILE" 2> /dev/null)"
  local g="$(echo ${GAPS[@]} | tr " " ",")"
  local c="$(hyprctl monitors \
  | awk -v c="$HEIGHT $WIDTH $DOCK $g" '
    /^Monitor/ { m = $2 }
    /^\s*scale:/ { s = $2 }
    /^\s*focused: yes/ { print m,s,c }')"
  local c_inds="$C_IND_H $C_IND_W $C_IND_D"
  local literals="$LITERAL_H $LITERAL_W $LITERAL_D"
  echo "$c $c_inds $literals" > "$CTX_FILE"
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
  [ -d "$CACHE_DIR" ] || mkdir -p "$CACHE_DIR"
  in_ws || hyprctl dispatch movetoworkspace "special:$WORKSPACE"
  resolve_hwd && unchanged && sh "$SET_FILE" && return
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
