#!/usr/bin/env bash

#      ██╗  ██╗██╗   ██╗██████╗ ██████╗       #
#      ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗      #
#      ███████║ ╚████╔╝ ██████╔╝██████╔╝      #
#      ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗      #
#      ██║  ██║   ██║   ██║     ██║  ██║      #
#      ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝      #
#                                             #
#    ██████╗  █████╗ ███╗   ██╗██╗ ██████╗    #
#    ██╔══██╗██╔══██╗████╗  ██║██║██╔════╝    #
#    ██████╔╝███████║██╔██╗ ██║██║██║         #
#    ██╔═══╝ ██╔══██║██║╚██╗██║██║██║         #
#    ██║     ██║  ██║██║ ╚████║██║╚██████╗    #
#    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝    #
#    ___        ___ _                  __     #
#   | _ )_  _  | _ \ |  _  _ _ _ __ __/  \    #
#   | _ \ || | |   / |_| || | ' \\ \ / () |   #
#   |___/\_, | |_|_\____\_, |_||_/_\_\\__/    #
#        |__/           |__/                  #


workdir="$(dirname "$0")"
temp="$workdir/temp.panic"
data_base="panic_data"
awk_compress="$workdir/compress-state.awk"
awk_panic="$workdir/gen-panic.awk"
awk_unpanic="$workdir/gen-unpanic.awk"
awk_unpause="$workdir/gen-unpause.awk"
awk_info="$workdir/gen-info.awk"
delta="10"


# get options and overwrite variables
while getopts "d:s:pih" arg; do
  case $arg in
  d)
    delta="$OPTARG"
    ;;
  s)
    waybar_signal="$OPTARG"
    ;;
  p)
    force_panic="yes"
    ;;
  i)
    output_info="yes"
    ;;
  *)
    echo "Usage: $(basename $0) [OPTIONS]"
    printf "\nOptions:\n"
    echo "  -d <DELTA>   Shift each workspace by this amount     [default: 10]"
    echo "  -s <SIGNAL>  Send signal RTMIN+<SIGNAL> to waybar    [default: '']"
    echo "               Does nothing if <SIGNAL> is empty                    "
    echo "  -p           Force panic, even if panic data exists               "
    echo "  -i           Print information for waybar and exit                "
    echo "  -h           Print this help message and exit                     "
    exit 1
  esac
done
shift $(($OPTIND-1))


function last_data_path {
  ls "$workdir/$data_base"* 2> /dev/null | tail -1
}

function last_data_num {
  basename "$(last_data_path)" | tr -d "$data_base" 2> /dev/null \
  || echo ""
}

function new_data_num {
  echo "$(("$(last_data_num)" + 1))"
}

function new_data_path {
  echo "$workdir/$data_base$(new_data_num)"
}

function waybar_info {
  if [ "$(last_data_path)" ]; then
    wb_text="Panic Mode"
    info="$(awk -f "$awk_info" "$(last_data_path)")"
    wb_tooltip="Restore State $(last_data_num) $info"
    wb_class="panicked"
  else
    wb_text=""
    wb_tooltip="Currently unpanicked"
    wb_class="unpanicked"
  fi

  printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' \
    "$wb_text" \
    "$wb_tooltip" \
    "$wb_class"
}

function player_status {
  while read player; do
    printf "%s %s\n" "$player" "$(playerctl status -p "$player")"
  done
}

function player_data {
  playerctl -l \
  | player_status \
  | awk '
    BEGIN { print "\n# Players" }
    $2 == "Playing" { print $1 }'
}


if [ "$output_info" != "" ]; then
  waybar_info
  exit 0
fi

hyprctl monitors | awk -f "$awk_compress" > "$temp"
if command -v playerctl; then
  player_data >> "$temp" \ # Save active players
  playerctl pause -a       # Pause all players
fi

if [ "$(last_data_path)" -a -z "$force_panic" ]; then
  # UNPANIC
  data="$(last_data_path)"
  eval "$(awk -v d="0" -f "$awk_panic" "$temp")"  # Toggle off special workspaces
  eval "$(awk -f "$awk_unpanic" "$data" "$temp")" # Restore the monitor state before panicking
  command -v playerctl && eval "$(awk -f "$awk_unpause" "$data")" # Unpause previously active players
  rm "$temp" "$data"
else
  # PANIC
  # Send each monitor to it's active workspace + delta
  # Also, toggle off special workspaces
  eval "$(awk -v d="$delta" -f "$awk_panic" "$temp")"
  command -v makoctl && makoctl dismiss --all # Dismiss notifications
  pkill wofi 2> /dev/null                     # Close menu if open
  mv "$temp" "$(new_data_path)"
fi

[ -z "$waybar_signal" ] \
|| pkill -RTMIN+"$waybar_signal" waybar
