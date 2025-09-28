#!/usr/bin/env bash

# Get current workspace
cur="$(hyprctl monitors \
| awk '
  /active workspace/ { w = $3 }
  /focused: yes/ { print w }')"

# Check if LibreWolf is open
# on current workspace
isopen="$(hyprctl clients \
| awk -v t="$cur" '
  /workspace:/ { w = $2 }
  /initialTitle: LibreWolf/ \
  && w == t {
    print "1"
  }')"

if [ -z "$isopen" ]; then
  [ "$#" -gt "1" ] \
  && librewolf "$@" \
  || librewolf --new-window "$@"
else
  for a in "$@"; do
    librewolf --new-tab "$a"
  done
fi
