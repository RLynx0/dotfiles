BEGIN { sec = 0 }
/^#/ { sec += 1 }

sec == 1 && /^[^#\n]/ && $1 { print "hyprctl dispatch focusmonitor", $1 }
sec == 1 && /^[^#\n]/ && $3 { print "hyprctl dispatch togglespecialworkspace", $3 }
sec == 1 && /^[^#\n]/ && $2 { print "hyprctl dispatch workspace", ($2 + d) }
