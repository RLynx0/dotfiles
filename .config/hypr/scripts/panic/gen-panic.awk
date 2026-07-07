/^#/ {
  sec = $0
  next
}

sec ~ /^# Monitor/ {
  if ($1) print "hyprctl dispatch 'hl.dsp.focus({ monitor = \"" $1 "\" })'"
  if ($3) print "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"" $3 "\")'"
  if ($2) print "hyprctl dispatch 'hl.dsp.focus({ workspace = " ($2 + d) " })'"
}
