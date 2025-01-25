#!/usr/bin/bash

property="$1"
target="$2"
time="${3:-2}"
timestep="${4:-0.025}"

val="$(busctl --user -- get-property rs.wl-gammarelay / rs.wl.gammarelay "$property")"
char="${val% *}"
val="${val#* }"

d="$(calc "($target - $val) * $timestep / $time" | tr -d "\t")"
[ "$d" == "0" ] && exit
for v in $(seq "$val" "$d" "$target" ); do
  [ "$char" == "q" ] && v="$(calc "round($v)" | tr -d "\t")"
  busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay "$property" "$char" "$v"
  sleep $timestep
done
