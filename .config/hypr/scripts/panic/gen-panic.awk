/^#/ {
  sec = $0
  next
}

sec ~ /^# Monitor/ {
  if ($1) print "hyprctl dispatch focusmonitor", $1
  if ($3) print "hyprctl dispatch togglespecialworkspace", $3
  if ($2) print "hyprctl dispatch workspace", ($2 + d)
}
