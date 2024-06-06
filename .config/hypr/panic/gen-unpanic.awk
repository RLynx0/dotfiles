NR == FNR {
  w[$1] = $2
  s[$1] = $3
  next
}

w[$1] {
  print "hyprctl dispatch focusmonitor", $1
  print "hyprctl dispatch workspace", w[$1]
}

s[$1] {
  print "hyprctl dispatch togglespecialworkspace", s[$1]
}
