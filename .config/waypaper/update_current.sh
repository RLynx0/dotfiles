#!/usr/bin/env bash

WAYPAPER_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}/waypaper"
CURRENT="$WAYPAPER_HOME/current_wallpaper"
path="$(awk -F ' *= *' -v h="$HOME" '$1 == "wallpaper" { gsub("~", h, $2); print $2 }' "$WAYPAPER_HOME/config.ini")"
ln -sf "$path" "$CURRENT"
