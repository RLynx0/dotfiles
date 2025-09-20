#!/usr/bin/env bash

target="$1"
active="$(hyprctl activeworkspace | awk '{ print $3; exit }')"

echo "swapping from $active to $target"
active_windows="$(hyprctl clients \
| awk -v a="$active" '
  /^\s*workspace:/ { w = $2 == a }
  w && /^\s*pid:/ { print $2 }')"
target_windows="$(hyprctl clients \
| awk -v t="$target" '
  /^\s*workspace:/ { w = $2 == t }
  w && /^\s*pid:/ { print $2 }')"

for w in $target_windows; do
  hyprctl dispatch focuswindow "pid:$w"
  hyprctl dispatch movetoworkspace "$active"
done
for w in $active_windows; do
  hyprctl dispatch focuswindow "pid:$w"
  hyprctl dispatch movetoworkspace "$target"
done
