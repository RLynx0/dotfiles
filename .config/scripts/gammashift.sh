#!/usr/bin/bash

PRECISION="3"
property="$1"
input_val="$2"
time="${3:-"2"}"
timestep="${4:-"0.025"}"

[[ "$input_val" =~ ^([+*/-]?)\s*([0-9]+(\.[0-9]+)?)$ ]] \
&& op="${BASH_REMATCH[1]}" && target="${BASH_REMATCH[2]}"
val="$(busctl --user -- get-property rs.wl-gammarelay / rs.wl.gammarelay "$property")"
[ -z "$target" ] && exit 1; char="${val% *}"; val="${val#* }"
[ -z "$op" ] || target="$(calc -p "round($val $op $target, $PRECISION)")"
d="$(calc -p "round(($target - $val) * $timestep / $time, $PRECISION)")"
echo "$val -> $target (${time}s)" > /dev/stderr
[ "$d" == "0" ] && exit
for v in $(seq "$val" "$d" "$target" ); do
  [ "$char" == "q" ] && v="$(calc -p "round($v)")"
  busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay "$property" "$char" "$v"
  sleep $timestep
done
