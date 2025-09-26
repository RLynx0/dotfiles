#!/bin/bash

default_theme="darklynx"
RESET='\033[0m'

function load_theme_simple {
  R='\033[38;2;255;0;0m'
  O='\033[38;2;255;127;0m'
  Y='\033[38;2;255;255;0m'
  G='\033[38;2;0;255;0m'
  C='\033[38;2;0;255;255m'
  B='\033[38;2;0;0;255m'
  M='\033[38;2;255;0;255m'
}

function load_theme_edge {
  R='\033[38;2;173;46;74m'
  O='\033[38;2;173;76;46m'
  Y='\033[38;2;173;118;46m'
  G='\033[38;2;71;173;46m'
  C='\033[38;2;46;173;141m'
  B='\033[38;2;61;124;179m'
  M='\033[38;2;122;46;173m'
}

function load_theme_darklynx {
  R='\033[38;2;208;88;80m'
  O='\033[38;2;208;128;80m'
# Y='\033[38;2;208;176;128m'
  Y='\033[38;2;208;192;128m'
  G='\033[38;2;96;208;160m'
# C='\033[38;2;96;192;192m'
  C='\033[38;2;96;208;216m'
  B='\033[38;2;80;160;208m'
  M='\033[38;2;192;128;216m'
}


function parse_rgb {
  echo "$1" \
  | awk -v t="$2" -F '[\t ]*[,;][\t ]*' '{
    printf "%s=\"", t
    printf "\\\\033[38;2;"
    printf "$(calc \"%s\" | tr -d \"\\t\");", $1
    printf "$(calc \"%s\" | tr -d \"\\t\");", $2
    printf "$(calc \"%s\" | tr -d \"\\t\")m", $3
    printf "\"\n"
  }'
}

function parse_theme {
  awk -F '[\t ]*=[\t ]*' '
    BEGIN { IGNORECASE = 1 }

    { t = 0 }
    /^\s*(r(ed)?|determination|frisk|chara)\s*=/  { t = "R" }
    /^\s*(o(range)?|bravery)\s*=/                 { t = "O" }
    /^\s*(y(ellow)?|justice|clover)\s*=/          { t = "Y" }
    /^\s*(g(reen)?|kindness)\s*=/                 { t = "G" }
    /^\s*(c(yan)?|a(qua)?|patience)\s*=/          { t = "C" }
    /^\s*(b(lue)?|integrity)\s*=/                 { t = "B" }
    /^\s*(m(agenta)?|p(urple)?|perseverance)\s*=/ { t = "M" }
    /^\s*$/ { next }

    t && $2 ~ /#([0-9]|[a-f]){6}\s*;?\s*$/ {
      printf "%s=\"", t
      printf "\\\\033[38;2;"
      printf "$(calc \"0x%s\" | tr -d \"\\t\");", substr($2, 2, 2)
      printf "$(calc \"0x%s\" | tr -d \"\\t\");", substr($2, 4, 2)
      printf "$(calc \"0x%s\" | tr -d \"\\t\")m", substr($2, 6, 2)
      printf "\"\n"
      next
    }

    t && $2 ~ /^([0-9]+\s*[,;]\s*){2}[0-9]+\s*;?\s*$/ &&
    $2 ~ /^(0*([0-1]?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\s*([,;]\s*|;?\s*$)){3}/ {
      printf "eval \"$(parse_rgb \"%s\" \"%s\")\"\n", $2, t
      next
    }

    {
      # Fallback
      printf "printf \"\\\\033[0;31mignored invalid: "
      printf "\\\"%s\\\" (%s)\\n\\\\033[0m\" >&2\n", $0, NR
    }
  '
}


function tiny {
  printf " $O♥ $M♥ \n"
  printf "$Y♥ $R♥ $B♥\n"
  printf " $G♥ $C♥ \n"
}

function small {
  printf "    $O▄ ▄     $M▄ ▄    \n"
  printf "    $O▀█▀     $M▀█▀    \n"
  printf "                   \n"
  printf "$Y▄ ▄     $R▄ ▄     $B▄ ▄\n"
  printf "$Y▀█▀     $R▀█▀     $B▀█▀\n"
  printf "                   \n"
  printf "    $G▄ ▄     $C▄ ▄    \n"
  printf "    $G▀█▀     $C▀█▀    $RESET\n"
}

function medium {
  printf "      $O▄██▄██▄     $M▄██▄██▄      \n"
  printf "      $O▀█████▀     $M▀█████▀      \n"
  printf "      $O  ▀█▀       $M  ▀█▀        \n"
  printf "                               \n"
  printf "                               \n"
  printf "$Y▄██▄██▄     $R▄██▄██▄     $B▄██▄██▄\n"
  printf "$Y▀█████▀     $R▀█████▀     $B▀█████▀\n"
  printf "$Y  ▀█▀       $R  ▀█▀       $B  ▀█▀  \n"
  printf "                               \n"
  printf "                               \n"
  printf "      $G▄██▄██▄     $C▄██▄██▄      \n"
  printf "      $G▀█████▀     $C▀█████▀      \n"
  printf "      $G  ▀█▀       $C  ▀█▀        $RESET\n"
}

function large {
  printf "       $O ▄▄   ▄▄      $M ▄▄   ▄▄        \n"
  printf "       $O████▄████     $M████▄████       \n"
  printf "       $O█████████     $M█████████       \n"
  printf "       $O ▀█████▀      $M ▀█████▀        \n"
  printf "       $O   ▀█▀        $M   ▀█▀          \n"
  printf "                                     \n"
  printf "$Y▄██▄ ▄██▄     $R▄██▄ ▄██▄     $B▄██▄ ▄██▄\n"
  printf "$Y█████████     $R█████████     $B█████████\n"
  printf "$Y▀███████▀     $R▀███████▀     $B▀███████▀\n"
  printf "$Y  ▀███▀       $R  ▀███▀       $B  ▀███▀  \n"
  printf "$Y    ▀         $R    ▀         $B    ▀    \n"
  printf "       $G ▄▄   ▄▄      $C ▄▄   ▄▄        \n"
  printf "       $G████▄████     $C████▄████       \n"
  printf "       $G█████████     $C█████████       \n"
  printf "       $G ▀█████▀      $C ▀█████▀        \n"
  printf "       $G   ▀█▀        $C   ▀█▀          $RESET\n"
}

function dog_stand {
  local Z='\033[49m' # Default Background
  local D='\033[30m' # Black Foreground
  local W='\033[47m' # White Background
  printf "         $D▄$W▀$Z▄$W▀▀▀▀$Z▄$W▀$Z▄ \n"
  printf "        ▄$W▀        █$Z \n"
  printf "▄$W▀$Z▄  ▄▄$W▀▀    ▀  ▀  █$Z\n"
  printf "█$W ▀▀▀       ▄ ▀█ ▄ █$Z\n"
  printf "█$W            ▀▀▀▀  █$Z\n"
  printf "█$W                  █$Z\n"
  printf "▀$W▄                 █$Z\n"
  printf " █$W  ▄▄  ▄▄▄▄  ▄▄  █$Z \n"
  printf " ▀$W▄ █$Z▀$W▄ █$Z  ▀$W▄ █$Z▀$W▄ █$Z \n"
  printf "   ▀   ▀     ▀   ▀  $RESET\n"
}

function dog_sleep {
  local Z='\033[49m' # Default Background
  local D='\033[30m' # Black Foreground
  local W='\033[47m' # White Background
  printf "    $D▄▄▄▄▄▄$W▀▀▀▀▀▀▀$Z▄▄▄      \n"
  printf "  ▄$W▀                ▀▀$Z▄   \n"
  printf " █$W     █  ▀▄           █$Z  \n"
  printf "█$W▀     ▄ █▀█   █▄      █$Z  \n"
  printf " █$W▄    ▀  ▄▀  ▄▄█      ▀$Z▄ \n"
  printf " █$W▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▄▄▄▄▄█▄▄█$RESET\n"
}

function dog_rand {
  case "$((RANDOM % 3))" in
    0|1) dog_stand ;;
    2)   dog_sleep ;;
  esac
}

function maybe_dog {
  rand="$((RANDOM % 50))"
  [ "$rand" -eq 0 ] && dog_rand
}


function print_usage {
  echo "Usage: $(basename $0) [-t <DEFAULT THEME>] [-f <THEME FILE>] tiny|small|medium|large"
  echo "Run $(basename $0) -h for a detailed help message"
}

function print_help {
  echo "Usage: $(basename $0) [OPTIONS] <SIZE>"
  printf "\nArguments:\n"
  echo "  <SIZE>  Set the size that SOULs should be printed with"
  echo "          Can be one of these values:                   "
  echo "          * t | tiny                                    "
  echo "          * s | small                                   "
  echo "          * m | medium                                  "
  echo "          * l | large                                   "
  printf "\nOptions:\n"
  echo "  -t <DEFAULT THEME>  Sets the default color theme to use       "
  echo "                      Available themes are:                     "
  echo "                      * simple                                  "
  echo "                      * darklynx                                "
  echo "                                                                "
  echo "  -f <THEME FILE>     Path to a theme configuration file        "
  echo "                      Each line configures the color of one SOUL"
  echo "                      The configuration is case insensitive     "
  echo "                      Whitespace around tokens is ignored       "
  echo "                      Use the format <KEY>=<COLOR>              "
  echo "                                                                "
  echo "                      Valid keys are:                           "
  echo "                      * r | red | determination | frisk | chara "
  echo "                      * o | orange | bravery                    "
  echo "                      * y | yellow | justice | clover           "
  echo "                      * g | green | kindness                    "
  echo "                      * b | blue | integrity                    "
  echo "                      * c | a | cyan | aqua | patience          "
  echo "                      * p | m | purple | magenta | perseverance "
  echo "                                                                "
  echo "                      Valid Color formats are:                  "
  echo "                      * Hex    #0088ff                          "
  echo "                      * RGB    0, 127, 255                      "
  echo "                               0; 127; 255                      "
  echo "                                                                "
  echo "                      Examples:                                 "
  echo "                      * Red = #ff4220                           "
  echo "                      * green=0;255;0;                          "
  echo "                      * BLUE = 20, 100, 255                     "
  echo "                      * m    = 230,80,255;                      "
  echo "                                                                "
  echo "  -s                  Show ANSI codes for used colors and exit  "
  echo "  -h                  Print this help message                   "
}


while getopts "t:f:sh" arg; do
    case $arg in
    t)
      default_theme="$OPTARG"
      ;;
    f)
      theme_file="$OPTARG"
      ;;
    s)
      show_value="yes"
      ;;
    h)
      print_help
      exit 0
      ;;
    *)
      print_usage >&2
      exit 1
    esac
done
shift $(($OPTIND-1))

if [ "$default_theme" == "darklynx" ]; then
  load_theme_darklynx
elif [ "$default_theme" == "simple" ]; then
  load_theme_simple
elif [ "$default_theme" == "edge" ]; then
  load_theme_edge
else
  echo "Available themes: darklynx, simple, edge" >&2
  exit 1
fi

[ ! -z "$theme_file" ] && eval "$(cat "$theme_file" | parse_theme)"
[ ! -z "$show_value" ] && printf \
  "$R# R='%s'\n$O# O='%s'\n$Y# Y='%s'\n$G# G='%s'\n$C# C='%s'\n$B# B='%s'\n$M# M='%s'\n" \
  "$R" "$O" "$Y" "$G" "$C" "$B" "$M" \
  && exit

if [ "$1" == "tiny" -o "$1" == "t" ]; then
  maybe_dog || tiny
elif [ "$1" == "small" -o "$1" == "s" ]; then
  maybe_dog || small
elif [ "$1" == "medium" -o "$1" == "m" ]; then
  maybe_dog || medium
elif [ "$1" == "large" -o "$1" == "l" ]; then
  maybe_dog || large
elif [ "$1" == "dog" -o "$1" == "d" ]; then
  dog_rand
else
  print_usage >&2
  exit 1
fi
