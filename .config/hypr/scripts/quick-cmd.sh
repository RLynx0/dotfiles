#!/bin/bash

CTX_FILE="/tmp/quick-$2-cmd.ctx.tmp"
SET_FILE="/tmp/quick-$2-cmd.set.tmp"
CMD_CLASS="${CMD_CLASS:-"quick-$2-cmd"}"
WORKSPACE="${WORKSPACE:-"quick-$2-cmd"}"
TERMINAL="${TERMINAL:-"kitty"}"
HEIGHT="${HEIGHT:-"100%"}"
WIDTH="${WIDTH:-"40%"}"
DOCK="${1:-"ur"}"

[ -z "$2" ] || command -v "$2" > /dev/null || { echo "'$2' is not installed" >&2; exit 1; }
command -v "$TERMINAL" > /dev/null || { echo "'$TERMINAL' is not installed" >&2; exit 1; }
command -v hyprctl > /dev/null || { echo "'hyprctl' is not installed" >&2; exit 1; }
command -v calc > /dev/null || { echo "'calc' is not installed" >&2; exit 1; }

BORDER="$(hyprctl getoption general:border_size | head -1 | awk '{ print $2 }')"
GAPS=($(hyprctl getoption general:gaps_out | head -1 | awk -F ': ' '{ print $2 }'))
GAP_T="${GAPS[0]}"; GAP_R="${GAPS[1]}";
GAP_B="${GAPS[2]}"; GAP_L="${GAPS[3]}";
OFF_Y="$(calc -p "round(($GAP_T - $GAP_B) / 2)")"

function pos {
  hyprctl activewindow \
  | awk '/^\s*at:/ { print $2 }' \
  | tr "," " ";
}

function probe_reserved {
  hyprctl dispatch centerwindow 0 > /dev/null; p0=($(pos))
  hyprctl dispatch centerwindow 1 > /dev/null; p1=($(pos))
  x0="${p0[0]}"; y0="${p0[1]}"; x1="${p1[0]}"; y1="${p1[1]}"
  ox="$(calc -p "2 * ($x1 - $x0 + $BORDER) + $GAP_L + $GAP_R")"
  oy="$(calc -p "2 * ($y1 - $y0 + $BORDER) + $GAP_T + $GAP_B")"
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
  while true; do already_open && break; sleep 0.01; done
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

already_open || open_cmd "$2" > /dev/null
toggle_view                   > /dev/null
focused && setup              > /dev/null
exit 0
