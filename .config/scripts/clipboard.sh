#!/usr/bin/env bash

P_COPY="📋 Copy clipboard entry 📋"
P_DEL="🧨 Delete clipboard entry 🧨"
P_DELALL="⚠️ Really wipe clipboard? ⚠️"
DEL_ENTRY="🧨 Delete Entry 🧨"
DELALL_ENTRY="⚠️ DELETE ALL ⚠️"
DELALL_CANCEL="💚 No 💚"
DELALL_CONFIRM="🧨 Yes 🧨"

function setup {
  [ -z "$(cliphist list)" ] && {
    notify-send "Clipboard is empty!"
    echo "No clipboard entries!" 1>&2
    exit 1
  }
  pkill wofi
}

function run_copy {
  setup
  COPRES="$(cliphist list | wofi --dmenu -ip "$P_COPY")"
  [ "$COPRES" != "" ] && printf "%s" "$COPRES" | cliphist decode | wl-copy
}

function list_delete {
  printf "%s\n%s" "$(cliphist list)" "$DELALL_ENTRY"
}

function run_delete_all {
  setup
  DELRES="$(printf "%s\n%s" "$DELALL_CANCEL" "$DELALL_CONFIRM" | wofi --dmenu -ip "$P_DELALL")"
  [ "$DELRES" == "$DELALL_CONFIRM" ] && cliphist wipe
}

function run_delete {
  setup
  DELRES="$(list_delete | wofi --dmenu -ip "$P_DEL")"
  if [ "$DELRES" == "$DELALL_ENTRY" ]; then
    run_delete_all
  else
    printf "%s" "$DELRES" | cliphist delete
  fi
}

function list_general {
  printf "%s\n%s" "$(cliphist list)" "$DEL_ENTRY"
}

function run_general {
  setup
  COPRES="$(list_general | wofi --dmenu -ip "$P_COPY")"
  if [ "$COPRES" == "$DEL_ENTRY" ]; then
    run_delete
  elif [ "$COPRES" != "" ]; then
     printf "%s" "$COPRES" | cliphist decode | wl-copy
  fi
}

if [ "$1" == "copy" ]; then
  run_copy
elif [ "$1" == "delete" ]; then
  run_delete
elif [ -z "$1" ]; then
  run_general
else
  echo "Usage: $(basename "$0") [copy|delete]" 1>&2
  exit 1
fi
