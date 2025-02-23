#!/bin/bash

LMARGIN="2"

IN_SELECT="select"; IN_ENTER="confirm"; IN_QUIT="quit"
IN_U="up"; IN_D="down"; IN_L="left"; IN_R="right"
IN_NEXT="next"; IN_PREV="previous"

MAX_PAC_LEN="0"
CURRENT_TAB=""
declare -a ALL_TABS
declare -A PACKAGES
declare -A PAC_DESC
declare -A PAC_LENS
declare -A TAB_TITLE

function n_t {
  declare -ga "$1"
  ALL_TABS+=("$1")
  CURRENT_TAB="$1"
  TAB_TITLE["$1"]="$2"
  TAB_FCOL_LEN["$1"]="0"
}

function n_p {
  local -n cur_tab="$CURRENT_TAB"
  PACKAGES["$1"]="true"
  PAC_DESC["$1"]="$2"
  cur_tab+=("$1")
  len="$(wc -m <<< "$1")"
  PAC_LENS["$1"]="$len"
  [ "$len" -gt "$MAX_PAC_LEN" ] \
  && MAX_PAC_LEN="$len"
}

function get_tui_input {
  while true; do
    IFS= read -rsn1 key
    [[ "$key" == $'\e' ]] && read -rsn2 key
    case "$key" in
      "[D" | "h") echo "$IN_L"; return ;;
      "[C" | "l") echo "$IN_R"; return ;;
      "[A" | "k") echo "$IN_U"; return ;;
      "[B" | "j") echo "$IN_D"; return ;;
      " ") echo "$IN_SELECT"; return ;;
      $'\t') echo "$IN_NEXT"; return ;;
      "[Z") echo "$IN_PREV"; return ;;
      "q") echo "$IN_QUIT"; return ;;
      "") echo "$IN_ENTER"; return ;;
    esac
  done
}

function draw_tab {
  tab_name="$1"
  for t in ${ALL_TABS[@]}; do
    [ "$t" = "$tab_name" ] \
    && printf "[%s] " "$t" \
    || printf " %s  " "$t"
  done
  printf -- "\n--- %s ---\n\n" "${TAB_TITLE["$tab_name"]}"

  local -n tab_packages="$tab_name"
  for i in $(seq "$2" "$3"); do
    package_name="${tab_packages["$i"]}"
    [ -n "${PACKAGES["$package_name"]}" ] && sel="+" || sel=" "
    [ "$i" = "$4" ] && sel="[$sel]" || sel=" $sel "
    printf "%s %s %s\n" "$sel" "$package_name" "${PAC_DESC["$package_name"]}"
  done
}

function tui_loop {
  local tab_cursor="0"
  local -a cursors; local -a firsts
  for tab_name in ${ALL_TABS[@]}; do
    cursors+=("0"); firsts+=("0")
    local -n tab="$tab_name"
    for package_name in ${tab[@]}; do
      pac_len="${PAC_LENS["$package_name"]}"
      offset="$(printf " %.0s" $(seq "$pac_len" "$MAX_PAC_LEN"))"
      PAC_DESC["$package_name"]="${offset}${PAC_DESC["$package_name"]}"
    done
  done

  while true; do
    tab_name="${ALL_TABS["$tab_cursor"]}"
    local -n tab_packages="$tab_name"
    nlines="$(($(tput lines) - 4))"
    npacks="${#tab_packages[@]}"
    [ "$npacks" -lt "$nlines" ] && nlines="$npacks"

    tc="$tab_cursor"; c="${cursors["$tc"]}"
    f="${firsts["$tc"]}"; l="$((f + "$nlines" - 1))"
    target="${tab_packages["$c"]}"
    clear; draw_tab "$tab_name" "$f" "$l" "$c"

    case "$(get_tui_input)" in
      "$IN_U") c="$((c - 1))" ;;
      "$IN_D") c="$((c + 1))" ;;
      "$IN_PREV" | "$IN_L") tc="$((tc - 1))" ;;
      "$IN_NEXT" | "$IN_R") tc="$((tc + 1))" ;;
      "$IN_SELECT") [ -n "${PACKAGES["$target"]}" ] \
        && PACKAGES["$target"]="" \
        || PACKAGES["$target"]="true" ;;
      "$IN_ENTER") echo "accept changes" ;;
      "$IN_QUIT") return ;;
    esac

    # Clamp cursors, adjust first position
    [ "$tc" -lt "0" ] && tc="$((tc + ${#ALL_TABS[@]}))"
    [ "$tc" -ge "${#ALL_TABS[@]}" ] && tc="$((tc - ${#ALL_TABS[@]}))"
    [ "$c" -lt "0" ] && c="$((c + $npacks))" && f="$((c + 1 - "$nlines"))"
    [ "$c" -ge "$npacks" ] && c="$((c - $npacks))" && f="$c"
    fcomf="$((c - "$LMARGIN"))"; lcomf="$((c + 1 + "$LMARGIN" - "$nlines"))"
    [ "$c" -ge "$LMARGIN" ] && [ "$f" -gt "$fcomf" ] && f="$fcomf"
    [ "$c" -lt "$(("$npacks" - LMARGIN))" ] && [ "$f" -lt "$lcomf" ] && f="$lcomf"
    firsts["$tab_cursor"]="$f"; cursors["$tab_cursor"]="$c"; tab_cursor="$tc"
  done
}

tui_loop
