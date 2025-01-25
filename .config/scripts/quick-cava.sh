#!/usr/bin/bash

CTX_FILE="/tmp/quick-cava.ctx.tmp"
CMD_CLASS="${CMD_CLASS:-"quick-view"}"
WORKSPACE="${WORKSPACE:-"cava-view"}"
TERMINAL="${TERMINAL:-"kitty"}"
HEIGHT="${HEIGHT:-"60%"}"
WIDTH="${WIDTH:-"60%"}"

function already_open {
  hyprctl clients | awk '
    /workspace:/ { w = $3 }
    /class:/ { print $2, w }
  ' | grep "$CMD_CLASS (special:$WORKSPACE)" > /dev/null
}

function focused {
  hyprctl activewindow | grep "class: $CMD_CLASS" > /dev/null
}

function changed {
  p="$(cat "$CTX_FILE")"
  c="$(hyprctl monitors | awk '
    /^Monitor/ { m = $2 }
    /^\s*scale:/ { s = $2 }
    /^\s*focused: yes/ { print m, s }
  ' | tee "$CTX_FILE")"
  [ "$c" != "$p" ]
}

function setup {
  is_pseudo="$(hyprctl activewindow \
  | awk '/^\s*pseudo:/ { print $2 }')"
  [ "$is_pseudo" == "0" ] && hyprctl dispatch pseudo
  hyprctl dispatch setfloating
  hyprctl dispatch resizeactive "exact $WIDTH $HEIGHT"
  hyprctl dispatch settiled
}

function open_and_move {
  hyprctl keyword windowrulev2 "float, class:$CMD_CLASS"
  "$TERMINAL" --class "$CMD_CLASS" cava & sleep 0.2
  hyprctl dispatch focuswindow "class:$CMD_CLASS"
  hyprctl dispatch movetoworkspace "special:$WORKSPACE"
  sleep 0.1; setup
}

already_open \
&& hyprctl dispatch togglespecialworkspace "$WORKSPACE" \
|| open_and_move > /dev/null
sleep 0.1; changed > /dev/null \
&& focused && setup > /dev/null
exit 0
