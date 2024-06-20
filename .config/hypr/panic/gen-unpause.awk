BEGIN { sec = 0 }
/^#/ { sec += 1 }

sec == 2 && /^[^#\n]/ && $1 {
  print "playerctl play -p " $1
}
