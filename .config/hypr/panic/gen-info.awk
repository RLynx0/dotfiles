BEGIN { sec = 0 }
/^#/ { sec += 1 }

sec == 1 && /^[^#\n]/ {
  printf "\\n- Monitor " $1 ", Workspace " $2
  if ($3) printf ", Special Workspace " $3
}
