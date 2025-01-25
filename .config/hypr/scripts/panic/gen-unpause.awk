/^#/ {
  sec = $0
  next
}

sec ~ /^# Players/ && $1 {
  print "playerctl play -p " $1
}
