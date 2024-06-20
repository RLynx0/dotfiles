/^#/ { sec = $0 }

sec != "Players" && /^[^#\n]/ && NR == FNR {
  w[$1] = $2
  s[$1] = $3
  next
}

sec != "Players" && /^[^#\n]/ && w[$1] {
  print "hyprctl dispatch focusmonitor", $1
  print "hyprctl dispatch workspace", w[$1]
}

sec != "Players" && /^[^#\n]/ && s[$1] {
  print "hyprctl dispatch togglespecialworkspace", s[$1]
}
