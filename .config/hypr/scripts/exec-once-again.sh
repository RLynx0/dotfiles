#!/usr/bin/env bash

HYPRLAND_CONFIG="${XDG_CONFIG_HOME:-"$HOME/.config"}/hypr/${1:-"hyprland.conf"}"

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
  comm="$1"; inst="${2}"
  echo "${inst/,/$'\n'}" | while read -r inst; do
    case "$inst" in
      'kill')
        basename="$(basename "$(awk '{ print $1 }' <<< "$comm")")"
        pid="$(pidof "$basename")" || continue
        echo "Killing '$basename'" >&2
        kill "$pid"
        ;;
      'exec')
        printf "Executing '%s' : " "$comm" >&2
        hyprctl dispatch exec "$comm" >&2
        ;;
      *) echo "Unknown #R instruction '$inst'" >&2 ;;
    esac
  done
}

exec_list="$(lookup_var "exec-once" | awk '/\s+#R:/')"

while read -r exec; do
  command="$(echo ${exec%%#R:*})"
  instruc="$(echo ${exec##*#R:})"
  process "$(resolve "$command")" "$instruc"
done <<< $exec_list
exit 0
