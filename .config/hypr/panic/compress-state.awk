/^Monitor/ { m = $2 }
/active workspace/ { w = $3 }

/special workspace/ {
  gsub(/\((special:)?|\)/, "", $4)
  s = $4
}

/focused: yes/ { f = (m" "w" "s) }
/focused: no/ { print m" "w" "s }
END { print f }
