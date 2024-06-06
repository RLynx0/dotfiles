#!/usr/bin/bash

#    ██╗  ██╗██╗   ██╗██████╗ ██████╗     #
#    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗    #
#    ███████║ ╚████╔╝ ██████╔╝██████╔╝    #
#    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗    #
#    ██║  ██║   ██║   ██║     ██║  ██║    #
#    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝    #
#                                         #
#  ██████╗  █████╗ ███╗   ██╗██╗ ██████╗  #
#  ██╔══██╗██╔══██╗████╗  ██║██║██╔════╝  #
#  ██████╔╝███████║██╔██╗ ██║██║██║       #
#  ██╔═══╝ ██╔══██║██║╚██╗██║██║██║       #
#  ██║     ██║  ██║██║ ╚████║██║╚██████╗  #
#  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝  #
#  ___        ___ _                  __   #
# | _ )_  _  | _ \ |  _  _ _ _ __ __/  \  #
# | _ \ || | |   / |_| || | ' \\ \ / () | #
# |___/\_, | |_|_\____\_, |_||_/_\_\\__/  #
#      |__/           |__/                #


workdir="$(dirname "$0")"
data="$workdir/data.panic"
temp="$workdir/temp.panic"
awk_compress="$workdir/compress-state.awk"
awk_panic="$workdir/gen-panic.awk"
awk_unpanic="$workdir/gen-unpanic.awk"
delta="10"


# get options and overwrite variables
while getopts "d:ph" arg; do
  case $arg in
  d)
    delta="$OPTARG"
    ;;
  p)
    rm "$data"
    ;;
  *)
    echo "Usage: $(basename $0) [OPTIONS]"
    printf "\nOptions:\n"
    echo "  -d <DELTA>  Shift each workspace by this amount     [default: 10]"
    echo "  -p          Force panic, even if panic data exists               "
    echo "  -h          Print this help message                              "
    exit 1
  esac
done
shift $(($OPTIND-1))


hyprctl monitors | awk -f "$awk_compress" > "$temp"
if [ -f "$data" ]; then
  # unpanic
  eval "$(awk -f "$awk_unpanic" "$data" "$temp")"
  command -v playerctl && playerctl play
  rm "$temp" "$data"
else
  # panic
  eval "$(awk -v d="$delta" -f "$awk_panic" "$temp")"
  command -v playerctl && playerctl -a pause
  command -v makoctl && makoctl dismiss --all
  mv "$temp" "$data"
fi
