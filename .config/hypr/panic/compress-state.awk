function align(str, ref) {
  max = length(ref) - length(str)
  for (i = 0; i < max; i++) str = (str" ")
  return str
}

BEGIN {
  lm = "# Monitor  "
  lw = "Workspace  "
  ls = "Special Workspace"
  print lm" "lw" "ls
}

/^Monitor/ {
  m = align($2, lm)
}

/active workspace/ {
  w = align($3, lw)
}

/special workspace/ {
  gsub(/\((special:)?|\)/, "", $4)
  s = align($4, ls)
}

/focused: yes/ { f = (m" "w" "s) }
/focused: no/ { print m" "w" "s }
END { print f }
