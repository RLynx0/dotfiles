#!/usr/bin/bash

STATE_HOME="${XDG_STATE_HOME:-"$HOME/.local/share"}/gammashift"
PRECISION="3"
property="$1"
input_val="$2"
time="${3:-"2"}"
timestep="${4:-"0.02"}"

[ "$input_val" = "undo" ] && B="$(cat "$STATE_HOME/$property.prev")"
[[ "$input_val" =~ ^([+*/-]?)\s*([0-9]+(\.[0-9]+)?)$ ]] \
&& op="${BASH_REMATCH[1]}" && B="${BASH_REMATCH[2]}"
[ -z "$B" ] && exit 1

A="$(busctl --user -- get-property rs.wl-gammarelay / rs.wl.gammarelay "$property")"
char="${A% *}"; A="${A#* }"
[ -d "$STATE_HOME" ] || mkdir "$STATE_HOME"
[ -z "$op" ] || B="$(calc -p "round($A $op $B, $PRECISION)")"
echo "$A" > "$STATE_HOME/$property.prev"
echo "$property : $A -> $B (${time}s)"

TA="$(date +%s%2N)"; TC="$TA"
TB="$(calc -p "$TA + 100 * $time")"
DT="$(calc -p "round(($B - $A) / ($TB - $TA), 2 * $PRECISION)")"
while [ true ]; do
  TC="$(date +%s%2N)"
  DX="$(calc -p "min($TB, $TC) - $TA")"
  C="$(calc -p "round($A + $DT * $DX, 2)")"
  [ "$char" = "q" ] && C="$(calc -p "round($C)")"
  busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay "$property" "$char" "$C"
  [ "$TC" -lt "$TB" ] && sleep "$timestep" || break
done
