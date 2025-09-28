#!/usr/bin/env bash

#      ██╗  ██╗██╗   ██╗██████╗ ██████╗       #
#      ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗      #
#      ███████║ ╚████╔╝ ██████╔╝██████╔╝      #
#      ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗      #
#      ██║  ██║   ██║   ██║     ██║  ██║      #
#      ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝      #
#    ███████╗ ██████╗  ██████╗ ███╗   ███╗    #
#    ╚══███╔╝██╔═══██╗██╔═══██╗████╗ ████║    #
#      ███╔╝ ██║   ██║██║   ██║██╔████╔██║    #
#     ███╔╝  ██║   ██║██║   ██║██║╚██╔╝██║    #
#    ███████╗╚██████╔╝╚██████╔╝██║ ╚═╝ ██║    #
#    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝    #
#    ___        ___ _                  __     #
#   | _ )_  _  | _ \ |  _  _ _ _ __ __/  \    #
#   | _ \ || | |   / |_| || | ' \\ \ / () |   #
#   |___/\_, | |_|_\____\_, |_||_/_\_\\__/    #
#        |__/           |__/                  #


function options {
    echo "auto"
    echo "0.5"
    echo "1.0"
    echo "2.0"
    echo "4.0"
}

function notify {
    id_file="/tmp/hyprzoom-previous-notification-id"
    if [ -r "$id_file" ]; then
      notify-send "$monitor scaled to $new_scale" -r "$(cat "$id_file")" -p > "$id_file"
    else
      notify-send "$monitor scaled to $new_scale" -p > "$id_file"
    fi
}

eval "$(hyprctl monitors | awk '
/^Monitor/ {m=$2}
/^\s*description/ {$1=""; d=$0}
/^\s*[0-9.@x]+ at / {o=$3}
/^\s*scale/ {s=$2}
/focused: yes/ {
    printf "monitor=\"%s\"\n", m
    printf "description=\"%s\"\n", d
    printf "offset=\"%s\"\n", o
    printf "scale=\"%s\"\n", s
    exit
}')"
description="${description# }"


pkill wofi
new_scale="$(\
    options \
    | wofi --dmenu --cache-file="/dev/null" -ip "Set scale for $monitor, currently at $scale"\
)"
[ "$new_scale" != "" ] \
&& hyprctl keyword monitor "desc:$description, preferred, $offset, $new_scale" \
&& sleep 0.2 \
&& notify \
&& waypaper --restore
