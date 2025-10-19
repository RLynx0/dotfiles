#!/usr/bin/env bash

LMARGIN_FRAC="8"
N="\033[K\n"

# INPUT CONSTANTS
TUI_IN_SPACE=" ";         TUI_IN_ENTER="";            TUI_IN_TAB=$'\t';           TUI_IN_SHIFT_TAB=$'\E[Z'
TUI_IN_ARROW_UP=$'\E[A';  TUI_IN_ARROW_DOWN=$'\E[B';  TUI_IN_ARROW_LEFT=$'\E[D';  TUI_IN_ARROW_RIGHT=$'\E[C'
TUI_IN_ESCAPE=$'\E';      TUI_IN_BACKSPACE=$'\177';   TUI_IN_DELETE=$'\E[3~';     TUI_IN_INSERT=$'\E[2~'
TUI_IN_END=$'\E[F';       TUI_IN_HOME=$'\E[H';        TUI_IN_PAGE_UP=$'\E[5~';    TUI_IN_PAGE_DOWN=$'\E[6~'

TAB_DRAW_LEN="0"
MAX_PAC_LEN="0"
CURRENT_TAB=""
declare -a ALL_TABS
declare -A PACKAGES
declare -A PAC_DISP
declare -A PAC_DESC
declare -A PAC_LENS
declare -A TAB_LENS
declare -A TAB_TITLE

function n_t {
  declare -ga "$1"
  ALL_TABS+=("$1")
  CURRENT_TAB="$1"
  TAB_TITLE["$1"]="$2"
  TAB_FCOL_LEN["$1"]="0"
  len="$(("$(wc -m <<< "$1")" - 1))"
  TAB_LENS["$1"]="$len"
  TAB_DRAW_LEN="$((TAB_DRAW_LEN + "$len" + 2))"
}

function n_p {
  local -n cur_tab="$CURRENT_TAB"
  PACKAGES["$1"]="true"
  PAC_DISP["$1"]="$1"
  PAC_DESC["$1"]="$2"
  cur_tab+=("$1")
  len="$(("$(wc -m <<< "$1")" - 1))"
  PAC_LENS["$1"]="$len"
  [ "$len" -gt "$MAX_PAC_LEN" ] \
  && MAX_PAC_LEN="$len"
}

function tui_get_input {
  IFS= read -rsn1 key
  while read -t 0.01 -rsn1 x; do key+=$x; done
  echo "$key"
}

function draw_tab {
  tab_name="$1"
  l_start="$2"
  l_end="$3"
  hover="$4"
  width="$5"
  empty="$6"

  used_width="0"
  for t in ${ALL_TABS[@]}; do
    tab_width="$(("${TAB_LENS["$t"]}" + 2))"
    used_width="$((used_width + tab_width))"
    [ "$used_width" -gt "$width" ] \
    && used_width="$tab_width" \
    && printf "$N"
    [ "$t" = "$tab_name" ] \
    && printf "[%s]" "$t" \
    || printf " %s " "$t"
  done
  printf -- "$N$N--- %s ---$N" "${TAB_TITLE["$tab_name"]}"

  desc_width="$(("$5" - "$MAX_PAC_LEN" - 6))"
  local -n tab_packages="$tab_name"
  for i in $(seq "$2" "$3"); do
    package_name="${tab_packages["$i"]}"
    disp="${PAC_DISP["$package_name"]}"
    desc="${PAC_DESC["$package_name"]}"
    desc="${desc:0:"$desc_width"}"
    [ -n "${PACKAGES["$package_name"]}" ] && sel="+" || sel=" "
    [ "$i" = "$hover" ] && sel="[$sel]" || sel=" $sel "
    printf "$N%s %s %s" "$sel" "$disp" "$desc"
  done

  printf "$N%.0s" $(seq "$empty")
  [ "$width" -ge "80" ] \
  && printf "> SPACE: toggle   A: toggle all   0: go to top   ENTER: save & quit   Q: cancel"
  printf "\033[K"
}

function toggle_package {
  [ -n "${PACKAGES["$1"]}" ] \
  && state="" || state="true"
  PACKAGES["$1"]="$state"
}

function toggle_tab {
  local -n tab_packages="$1"
  [ -n "${PACKAGES["$2"]}" ] \
  && state="" || state="true"
  for package in ${tab_packages[@]}; do
    PACKAGES["$package"]="$state"
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
      PAC_DISP["$package_name"]="${package_name}${offset}"
    done
  done

  while true; do
    tab_name="${ALL_TABS["$tab_cursor"]}"
    local -n tab_packages="$tab_name"
    width="$(tput cols)"
    height="$(tput lines)"
    addtabheight="$((TAB_DRAW_LEN / "$width"))"
    reserved="$((addtabheight + 4))"
    nlines="$((height - "$reserved" - 1))"
    npacks="${#tab_packages[@]}"
    [ "$npacks" -lt "$nlines" ] && nlines="$npacks"
    lmargin="$((nlines / "$LMARGIN_FRAC" + 1))"
    empty="$((height - "$reserved" - "$nlines"))"

    tc="$tab_cursor"; c="${cursors["$tc"]}"
    target="${tab_packages["$c"]}"
    f="${firsts["$tc"]}"; lcomf="$((npacks - "$nlines"))"
    [ "$f" -gt "$lcomf" ] && f="$lcomf"
    l="$((f + "$nlines" - 1))"
    printf "\e[H\e[?25l"
    draw_tab "$tab_name" "$f" "$l" "$c" "$width" "$empty"

    case "$(tui_get_input)" in
      "$TUI_IN_SHIFT_TAB" | "$TUI_IN_ARROW_LEFT" | "h") tc="$((tc - 1))" ;;
      "$TUI_IN_TAB" | "$TUI_IN_ARROW_RIGHT" | "l")      tc="$((tc + 1))" ;;
      "$TUI_IN_ARROW_DOWN" | "j")                       c="$((c + 1))" ;;
      "$TUI_IN_ARROW_UP" | "k")                         c="$((c - 1))" ;;
      "$TUI_IN_HOME" | "0")                             c="0"; f="0" ;;
      "$TUI_IN_ENTER")                                  echo "accept changes" ;;
      "$TUI_IN_SPACE")                                  toggle_package "$target" ;;
      "a")                                              toggle_tab "$tab_name" "$target" ;;
      "q")                                              return ;;
    esac

    # Clamp cursors, adjust first position
    [ "$tc" -lt "0" ] && tc="$((tc + ${#ALL_TABS[@]}))"
    [ "$tc" -ge "${#ALL_TABS[@]}" ] && tc="$((tc - ${#ALL_TABS[@]}))"
    [ "$c" -lt "0" ] && c="$((c + $npacks))" && f="$((c + 1 - "$nlines"))"
    [ "$c" -ge "$npacks" ] && c="$((c - $npacks))" && f="$c"
    lcomf="$((c - "$lmargin"))"; fcomf="$((c + 1 + "$lmargin" - "$nlines"))"
    [ "$c" -ge "$lmargin" ] && [ "$f" -gt "$lcomf" ] && f="$lcomf"
    [ "$c" -lt "$(("$npacks" - lmargin))" ] && [ "$f" -lt "$fcomf" ] && f="$fcomf"
    firsts["$tab_cursor"]="$f"; cursors["$tab_cursor"]="$c"; tab_cursor="$tc"
  done
}


# Essential system utilities
n_t Essential "Essential Packages"
n_p bash       "Bourne Again Shell"
n_p coreutils  "GNU core utilities (basic file, shell, and text manipulation utilities)"
n_p curl       "Command-line tool for transferring data with URLs"
n_p git        "Distributed version control system"
n_p wget       "Network utility to retrieve files from the web"
n_p htop       "Interactive process viewer"
n_p neovim     "Modern Vim-based text editor"

# Desktop Environment / Window Manager
n_t Desktop "Desktop Environment / Window Manager"
n_p hyprland    "The Hyprland window manager"
n_p waybar      "Highly customizable status bar for Wayland"
n_p waypaper    "Wayland wallpaper picker supporting multiple engines"
n_p wofi        "Launcher for Wayland (like rofi but for Wayland)"
n_p swaylock    "Screen locker for Wayland"
n_p mako        "Lightweight Wayland notification daemon"

# Development Tools
n_t Development "Development Tools"
n_p gcc         "GNU Compiler Collection"
n_p clang       "LLVM-based C/C++ compiler"
n_p make        "Build automation tool"
n_p cmake       "Cross-platform build system"
n_p python3     "Python programming language"
n_p nodejs      "JavaScript runtime"
n_p yarn        "Package manager for JavaScript"
n_p docker      "Containerization platform"
n_p rustup      "Rust language installer and version manager"
n_p go          "The Go programming language"
n_p jq          "Command-line JSON processor"

# Networking
n_t Networking "Networking Tools"
n_p nmap       "Network scanner"
n_p netcat     "Networking utility for reading/writing across networks"
n_p iproute2   "Networking utilities for Linux"
n_p openvpn    "Open-source VPN client"
n_p wireguard  "Fast, modern VPN protocol"
n_p speedtest-cli "Command-line internet speed test tool"

# Multimedia
n_t Multimedia "Multimedia Tools"
n_p mpv        "Lightweight media player"
n_p ffmpeg     "Multimedia framework for processing video and audio"
n_p imagemagick "Image editing and conversion tools"
n_p pulseaudio "Sound server for Linux"
n_p pipewire   "Next-gen audio and video server for Linux"
n_p pavucontrol "GUI volume control for PulseAudio"

# Productivity
n_t Productivity "Productivity Tools"
n_p zathura    "Minimalist document viewer"
n_p libreoffice "Open-source office suite"
n_p thunderbird "Email client"
n_p obsidian   "Markdown-based knowledge management app"
n_p calcurse   "Command-line calendar and scheduling app"

# Gaming
n_t Gaming "Gaming Tools"
n_p steam      "Steam client for Linux"
n_p lutris     "Open gaming platform for Linux"
n_p wine       "Compatibility layer for running Windows apps on Linux"
n_p proton-ge  "Custom Proton builds for better compatibility with Windows games"
n_p mangohud   "FPS and system performance overlay"

# Security & Privacy
n_t Security "Security and Privacy"
n_p gpg        "GNU Privacy Guard for encryption and signing"
n_p keepassxc  "Password manager"
n_p ufw        "Uncomplicated Firewall"
n_p tor        "Anonymity network"
n_p fail2ban   "Intrusion prevention system"

# System Monitoring
n_t Monitoring "System Monitoring Tools"
n_p btop       "Resource monitor similar to htop"
n_p glances    "Cross-platform monitoring tool"
n_p iotop      "Display I/O usage per process"
n_p iftop      "Network bandwidth monitoring"

# Virtualization
n_t Virtualization "Virtualization Software"
n_p qemu       "Emulator and virtualizer"
n_p virt-manager "GUI for managing virtual machines"
n_p vagrant    "Development environments manager"
n_p virtualbox "Virtual machine software"

# Fun / Misc
n_t Misc "Miscellaneous and Fun Packages"
n_p figlet     "Create ASCII text banners"
n_p lolcat     "Rainbow-colored text output"
n_p cowsay     "ASCII art cows that talk"
n_p fortune    "Display random quotes or wisdom"

tui_loop; clear; printf "\e[?25h"
