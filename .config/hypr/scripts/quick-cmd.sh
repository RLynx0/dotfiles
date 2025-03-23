#!/bin/bash

CTX_FILE="/tmp/quick-cmd.ctx.tmp"
SET_FILE="/tmp/quick-cmd.set.tmp"
CMD_CLASS="${CMD_CLASS:-"quick-cmd"}"
WORKSPACE="${WORKSPACE:-"quick-cmd"}"
TERMINAL="${TERMINAL:-"kitty"}"
WIDTH="${WIDTH:-"40%"}"
DOCK="${DOCK:-"r"}"

[ ! $(command -v "$TERMINAL") ] && echo "$TERMINAL is not installed" >&2 && exit 1
[ ! $(command -v hyprctl) ] && echo "hyprctl is not installed" >&2 && exit 1
[ ! $(command -v calc) ] && echo "calc is not installed" >&2 && exit 1

BORDER="$(hyprctl getoption general:border_size | head -1 | awk '{ print $2 }')"
GAPS=($(hyprctl getoption general:gaps_out | head -1 | awk -F ': ' '{ print $2 }'))
GAP_T="${GAPS[0]}"; GAP_R="${GAPS[1]}";
GAP_B="${GAPS[2]}"; GAP_L="${GAPS[3]}";
OFF_Y="$(calc -p "round(($GAP_T - $GAP_B) / 2)")"

function ypos {
  hyprctl activewindow | awk -F ',' '/^\s*at:/ { print $2 }'
}

function probe_reserved {
  hyprctl dispatch centerwindow 0 > /dev/null; y0="$(ypos)"
  hyprctl dispatch centerwindow 1 > /dev/null; y1="$(ypos)"
  calc -p "2 * ($y1 - $y0 + $BORDER) + $GAP_T + $GAP_B"
}

function already_open {
  hyprctl clients | awk '
    /workspace:/ { w = $3 }
    /class:/ { print $2, w }
  ' | grep "$CMD_CLASS (special:$WORKSPACE)" > /dev/null
}

function focused {
  hyprctl activewindow | grep "class: $CMD_CLASS" > /dev/null
}

function unchanged {
  p="$(cat "$CTX_FILE")"
  g="$(echo ${GAPS[@]} | tr " " ",")"
  c="$(hyprctl monitors \
  | awk -v g="$g" -v d="$DOCK" '
    /^Monitor/ { m = $2 }
    /^\s*scale:/ { s = $2 }
    /^\s*focused: yes/ { print m, s, g, d }
  ' | tee "$CTX_FILE")"
  [ "$c" == "$p" ]
}

function save_setup {
  hyprctl activewindow | awk '
    /^\s*size:/ { print "resizeactive -- \"exact "$2"\"" }
    /^\s*at:/ { print "moveactive -- \"exact "$2"\"" }
  ' | tr ',' ' ' | awk '{ print "hyprctl dispatch "$0 }
  ' > "$SET_FILE"
}

function open_and_move {
  hyprctl keyword windowrulev2 "float, class:$CMD_CLASS"
  "$TERMINAL" --class "$CMD_CLASS" & sleep 0.1
  hyprctl dispatch focuswindow "class:$CMD_CLASS"
  hyprctl dispatch movetoworkspace "special:$WORKSPACE"
}

function dock_horizontal {
  hyprctl dispatch movewindow "$1"
  if   [ "$1" == "l" ]; then hyprctl dispatch moveactive -- "$GAP_L 0"
  elif [ "$1" == "r" ]; then hyprctl dispatch moveactive -- "-$GAP_R 0"
  fi
}

function setup {
  unchanged && sh "$SET_FILE" && return
  hyprctl dispatch setfloating
  hyprctl dispatch resizeactive "exact $WIDTH 100%"
  hyprctl dispatch resizeactive -- "0 -$(probe_reserved)"
  hyprctl dispatch centerwindow 1
  hyprctl dispatch moveactive -- "0 $OFF_Y"
  dock_horizontal "$DOCK"
  save_setup
}

already_open \
&& hyprctl dispatch togglespecialworkspace "$WORKSPACE" \
|| open_and_move > /dev/null
focused && setup
exit 0
