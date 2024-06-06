$1 { print "hyprctl dispatch focusmonitor", $1 }
$3 { print "hyprctl dispatch togglespecialworkspace", $3 }
$2 { print "hyprctl dispatch workspace", ($2 + d) }
