#!/usr/bin/env bash

# ██╗     ██╗   ██╗███╗   ███╗███████╗███╗   ██╗ #
# ██║     ██║   ██║████╗ ████║██╔════╝████╗  ██║ #
# ██║     ██║   ██║██╔████╔██║█████╗  ██╔██╗ ██║ #
# ██║     ██║   ██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║ #
# ███████╗╚██████╔╝██║ ╚═╝ ██║███████╗██║ ╚████║ #
# ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ #
#      ___        ___ _                  __      #
#     | _ )_  _  | _ \ |  _  _ _ _ __ __/  \     #
#     | _ \ || | |   / |_| || | ' \\ \ / () |    #
#     |___/\_, | |_|_\____\_, |_||_/_\_\\__/     #
#          |__/           |__/                   #


if [ "$1" == "up" ]; then
  sign="+"
elif [ "$1" == "down" ]; then
  sign="-"
else
  echo "Usage: $(basename "$0") (up|down) [amount]" 1>&2
  exit 1
fi

if [ -z "$2" ]; then
  amount="5"
else
  amount="$2"
fi

id_file="/tmp/lumen-previous-notification-id"
updatedBrightness="$(brightnessctl set -- "${sign}${amount}%" | awk '/Current/ {print $4}' | tr -d '[()%]')"
N_Title="Lumen"
N_Body="Set brightness to ${updatedBrightness}%"
N_Hint="int:value:${updatedBrightness}"
N_Time="1000"

if [ -r "$id_file" ]; then
  notify-send "$N_Title" "$N_Body" -h "$N_Hint" -t "$N_Time" -r "$(cat "$id_file")" -p > "$id_file"
else
  notify-send "$N_Title" "$N_Body" -h "$N_Hint" -t "$N_Time" -p > "$id_file"
fi
