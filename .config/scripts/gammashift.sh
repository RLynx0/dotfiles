#!/usr/bin/env bash

PRECISION="3"
property="$1"
input_val="$2"
time="${3:-"2"}"
timestep="${4:-"0.02"}"

STATE_HOME="${XDG_STATE_HOME:-"$HOME/.local/share"}/gammashift"
TARGET_FILE="$STATE_HOME/$property.target"
UNDO_FILE="$STATE_HOME/$property.previous"
LOCK_FILE="$STATE_HOME/$property.lock"

[ -d "$STATE_HOME" ] || mkdir -p "$STATE_HOME"
[ -e "$TARGET_FILE" ] && X="$(cat "$TARGET_FILE")"
A="$(busctl --user -- get-property rs.wl-gammarelay / rs.wl.gammarelay "$property")"
char="${A% *}"; A="${A#* }"; X="${X:-"$A"}"

[ "$input_val" = "undo" ] && B="$(cat "$UNDO_FILE")"
[[ "$input_val" =~ ^([+*/-]?)\s*([0-9]+(\.[0-9]+)?)$ ]] \
&& op="${BASH_REMATCH[1]}" && B="${BASH_REMATCH[2]}"
[ -z "$B" ] && exit 1

[ -z "$op" ] || B="$(calc -p "round($X $op $B, $PRECISION)")"
echo "$$" > "$LOCK_FILE"
echo "$A" > "$UNDO_FILE"
echo "$B" > "$TARGET_FILE"
echo "$property : $A -> $B (${time}s)"

TA="$(date +%s%2N)"; TC="$TA"
TB="$(calc -p "$TA + 100 * $time")"
DT="$(calc -p "round(($B - $A) / ($TB - $TA), 2 * $PRECISION)")"
while [ "$(cat "$LOCK_FILE")" = "$$" ]; do
  TC="$(date +%s%2N)"
  DX="$(calc -p "min($TB, $TC) - $TA")"
  C="$(calc -p "round($A + $DT * $DX, 2)")"
  [ "$char" = "q" ] && C="$(calc -p "round($C)")"
  busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay "$property" "$char" "$C"
  if [ "$TC" -lt "$TB" ]; then sleep "$timestep"
  else rm "$LOCK_FILE" "$TARGET_FILE"; break; fi
done
