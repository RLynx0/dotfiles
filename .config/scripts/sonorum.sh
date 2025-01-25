#!/usr/bin/bash

# ███████╗ ██████╗ ███╗   ██╗ ██████╗ ██████╗ ██╗   ██╗███╗   ███╗ #
# ██╔════╝██╔═══██╗████╗  ██║██╔═══██╗██╔══██╗██║   ██║████╗ ████║ #
# ███████╗██║   ██║██╔██╗ ██║██║   ██║██████╔╝██║   ██║██╔████╔██║ #
# ╚════██║██║   ██║██║╚██╗██║██║   ██║██╔══██╗██║   ██║██║╚██╔╝██║ #
# ███████║╚██████╔╝██║ ╚████║╚██████╔╝██║  ██║╚██████╔╝██║ ╚═╝ ██║ #
# ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝ #
#               ___        ___ _                  __               #
#              | _ )_  _  | _ \ |  _  _ _ _ __ __/  \              #
#              | _ \ || | |   / |_| || | ' \\ \ / () |             #
#              |___/\_, | |_|_\____\_, |_||_/_\_\\__/              #
#                   |__/           |__/                            #


sink="@DEFAULT_AUDIO_SINK@"
limit="1.2"


function get_volume {
  updated_volume="$(wpctl get-volume "$sink" | awk '{print $2}')"
  volume_percent="$(calc "round($updated_volume * 100)" | awk '{print $1}')"
  volume_percent_scaled="$(calc "round($updated_volume / $limit * 100)" | awk '{print $1}')"
}

function notification {
  id_file="/tmp/volume-previous-notification-id"
  N_Time="1000"
  N_Title="Sonorum"

  if [ -r "$id_file" -a "$(cat "$id_file")" != "" ]; then
    notify-send "$N_Title" "$N_Body" -h "$N_Hint" -t "$N_Time" -r "$(cat "$id_file")" -p > "$id_file"
  else
    notify-send "$N_Title" "$N_Body" -h "$N_Hint" -t "$N_Time" -p > "$id_file"
  fi
}

function notification_volume {
  get_volume
  [ -z "$(wpctl get-volume "$sink" | awk '{print $3}')" ] || display_muted=" (muted)"

  N_Hint="int:value:$volume_percent_scaled"
  N_Body="Volume set to $volume_percent%$display_muted"

  notification
}

function notification_mute {
  if [ -z "$(wpctl get-volume "$sink" | awk '{print $3}')" ]; then
    get_volume
    
    N_Hint="int:value:$volume_percent_scaled"
    N_Body="Volume unmuted at ${volume_percent}%"
  else
    N_Hint="int:value:0"
    N_Body="Volume muted"
  fi

  notification
}


if [ -z "$2" ]; then
  amount="5"
else
  amount="$2"
fi

if [ "$1" == "up" ]; then
  wpctl set-volume -l "$limit" "$sink" "${amount}%+"
  notification_volume
elif [ "$1" == "down" ]; then
  wpctl set-volume "$sink" "${amount}%-"
  notification_volume
elif [ "$1" == "mute" ]; then
  wpctl set-mute "$sink" toggle
  notification_mute
else
  echo "Usage: $(basename "$0") (up [amount]|down [amount]|mute)" 1>&2
  exit 1
fi
