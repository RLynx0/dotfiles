#!/bin/bash

HYPRLAND_CONFIG="${XDG_CONFIG_HOME:-"$HOME/.config"}/hypr/hyprland.conf"

function lookup_var {
  awk -F "$1 *= *" '$2 { print $2 }' $HYPRLAND_CONFIG
}

function resolve {
  expr="$1"
  [[ "$expr" =~ \$([a-zA-Z0-9_-]+) ]] \
  && for var in "${BASH_REMATCH[@]:1}"; do
    rep="$(resolve "$(lookup_var "$var" | head -1)")"
    [ -z "$rep" ] && continue
    expr="$(awk -v v="$var" -v r="$rep" '
    { gsub("\\$"v, r, $0); print }' <<< $expr)"
  done
  echo "$expr"
}

function process {
  basename="$(basename "$(awk '{ print $1 }' <<< $1)")"
  [ ! "$(pidof $basename)" ] \
  && printf '$ %s : ' "$1" \
  && hyprctl dispatch exec "$1"
}

exec_list="$(lookup_var "exec-once")"
while read -r exec; do
  process "$(resolve "$exec")"
done <<< $exec_list
exit 0
