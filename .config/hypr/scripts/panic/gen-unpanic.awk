/^#/ {
  sec = $0
  next
}

sec ~ /^# Monitor/ && $0 {
  if (NR == FNR) {
    w[$1] = $2
    s[$1] = $3
    next
  }

  if (w[$1]) {
    print "hyprctl dispatch 'hl.dsp.focus({ monitor = \"" $1 "\" })'"
    print "hyprctl dispatch 'hl.dsp.focus({ workspace = " w[$1] " })'"
  }

  if (s[$1]) print "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"" s[$1] "\")'"
}
