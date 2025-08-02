/^#/ {
  sec = $0
  next
}

sec ~ /^# Monitor/ {
  if ($1) printf "\\n- Monitor %s", $1
  if ($2) printf ", Workspace %s", $2
  if ($3) printf ", Special Workspace %s", $3
}

sec ~ /^# Players/ && $1 {
  printf "\\n- Player <%s>", $1
}
