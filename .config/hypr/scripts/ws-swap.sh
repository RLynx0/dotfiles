#!/usr/bin/env bash

# 
# ██╗    ██╗███████╗      ███████╗██╗    ██╗ █████╗ ██████╗  #
# ██║    ██║██╔════╝      ██╔════╝██║    ██║██╔══██╗██╔══██╗ #
# ██║ █╗ ██║███████╗█████╗███████╗██║ █╗ ██║███████║██████╔╝ #
# ██║███╗██║╚════██║╚════╝╚════██║██║███╗██║██╔══██║██╔═══╝  #
# ╚███╔███╔╝███████║      ███████║╚███╔███╔╝██║  ██║██║      #
#  ╚══╝╚══╝ ╚══════╝      ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝      #
#           ___        ___ _                  __             #
#          | _ )_  _  | _ \ |  _  _ _ _ __ __/  \            #
#          | _ \ || | |   / |_| || | ' \\ \ / () |           #
#          |___/\_, | |_|_\____\_, |_||_/_\_\\__/            #
#               |__/           |__/                          #


target="$1"
active="$(hyprctl activeworkspace | awk '{ print $3; exit }')"
[ -z "$target" ] || [ "$target" == "$active" ] && exit

function windows_in_workspace {
  hyprctl clients | awk -v a="$1" '
    /^Window/ { w = $2 }
    /^\s*workspace:/ && $2 == a { print w }'
}

function focus_and_move {
  hyprctl dispatch focuswindow "address:0x$1"
  hyprctl dispatch movetoworkspace "$2"
}

echo "swapping from $active to $target"
active_windows="$(windows_in_workspace $active)"
target_windows="$(windows_in_workspace $target)"
for w in $target_windows; do focus_and_move $w $active; done
for w in $active_windows; do focus_and_move $w $target; done
