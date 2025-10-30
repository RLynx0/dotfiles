#!/usr/bin/env bash

readonly RESET='\033[0m'
readonly DEFAULT_MODE="medium"
readonly SELF="$(basename $0)"

function load_theme_simple {
  R='\033[31m'
  O='\033[33m'
  Y='\033[93m'
  G='\033[32m'
  C='\033[36m'
  B='\033[34m'
  M='\033[35m'
}

function load_theme_loreaccurate {
  R='\033[38;2;255;0;0m'
  O='\033[38;2;252;166;0m'
  Y='\033[38;2;255;255;0m'
  G='\033[38;2;0;192;0m'
  C='\033[38;2;66;252;255m'
  B='\033[38;2;0;60;255m'
  M='\033[38;2;213;53;217m'
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
  Y='\033[38;2;208;192;128m'
  G='\033[38;2;96;208;160m'
  C='\033[38;2;96;208;216m'
  B='\033[38;2;80;160;208m'
  M='\033[38;2;192;128;216m'
}


function parse_rgb {
  echo "$1" \
  | awk -v t="$2" -F '[\t ]*[,;][\t ]*' '{
    printf "%s=\"", t
    printf "\\\\033[38;2;"
    printf "$((16#%s));", $1
    printf "$((16#%s));", $2
    printf "$((16#%s))m", $3
    printf "\"\n"
  }'
}

function parse_theme {
  awk -F '[\t ]*=[\t ]*' '
    BEGIN { IGNORECASE = 1 }

    { t = 0 }

    /^\s*$/ { next }
    /^\s*(r(ed)?|determination|frisk|chara|kris)\s*=/ { t = "R" }
    /^\s*(o(range)?|bravery)\s*=/                     { t = "O" }
    /^\s*(y(ellow)?|justice|clover)\s*=/              { t = "Y" }
    /^\s*(g(reen)?|kindness)\s*=/                     { t = "G" }
    /^\s*(c(yan)?|a(qua)?|patience)\s*=/              { t = "C" }
    /^\s*(b(lue)?|integrity)\s*=/                     { t = "B" }
    /^\s*(m(agenta)?|p(urple)?|perseverance)\s*=/     { t = "M" }

    t && $2 ~ /^#([0-9]|[a-f]){6}\s*;?\s*$/ {
      printf "%s=\"", t
      printf "\\\\033[38;2;"
      printf "$((16#%s));", substr($2, 2, 2)
      printf "$((16#%s));", substr($2, 4, 2)
      printf "$((16#%s))m", substr($2, 6, 2)
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
  printf "          $D▄ ▄▄▄▄ ▄  \n"
  printf "         █$W ▀    ▀ █$Z \n"
  printf " ▄     ▄█$W    ▄  ▄ ▀$Z▄\n"
  printf "█$W █$Z▄▄$W▀▀       ▄▄   █$Z\n"
  printf "█$W           ▀▄▄█▄▀ █$Z\n"
  printf "█$W                  █$Z\n"
  printf "█$W                  █$Z\n"
  printf " █$W                ▄$Z▀\n"
  printf " █$W  ██  █$Z▀▀█$W  ██  █$Z \n"
  printf "  ▀$W▄$Z▀ ▀$W▄$Z▀   ▀$W▄$Z▀ ▀$W▄$Z▀ $RESET\n"
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
  echo "Usage: $SELF [-t <DEFAULT THEME>] [-F <INLINE THEME>] [-f <THEME FILE>] [t|s|m|l|d]"
  echo "Run $SELF -h for a detailed help message"
}

function print_help {
  echo "Usage: $SELF [OPTIONS] [MODE]"
  printf "\nArguments:\n"
  echo "  <MODE>  Set the size that SOULs should be printed with"
  echo "          Can be one of these values:"
  echo "          * t | tiny"
  echo "          * s | small"
  echo "          * m | medium       <- this is the default MODE"
  echo "          * l | large"
  echo "          * d | dog"
  printf "\nOptions:\n"
  echo "  -t <DEFAULT THEME>  Sets the default color theme to use"
  echo "                      Available themes are:"
  echo "                      * simple"
  echo "                      * loreaccurate"
  echo "                      * darklynx"
  echo "                      * edge"
  echo ""
  echo "  -f <THEME FILE>     Path to a theme configuration file"
  echo "                      Each line configures the color of one SOUL"
  echo "                      The configuration is case insensitive"
  echo "                      Whitespace around tokens is ignored"
  echo "                      Use the format <KEY>=<COLOR>"
  echo ""
  echo "                      Valid keys are:"
  echo "                      * r | red | determination | frisk | chara | kris"
  echo "                      * o | orange | bravery"
  echo "                      * y | yellow | justice | clover"
  echo "                      * g | green | kindness"
  echo "                      * b | blue | integrity"
  echo "                      * c | a | cyan | aqua | patience"
  echo "                      * p | m | purple | magenta | perseverance"
  echo ""
  echo "                      Valid Color formats are:"
  echo "                      * Hex    #0088ff"
  echo "                      * RGB    0, 127, 255"
  echo "                               0; 127; 255"
  echo ""
  echo "                      Examples:"
  echo "                      * Red = #ff4220"
  echo "                      * green=0;255;0;"
  echo "                      * BLUE = 20, 100, 255"
  echo "                      * m    = 230,80,255;"
  echo ""
  echo "  -v <THEME VAR>      Set the value of a single theme variable"
  echo "                      The format is the same as for theme files"
  echo ""
  echo "                      Examples:"
  echo "                      * $SELF -v 'RED = 128; 20; 20'"
  echo "                      * $SELF -vr=#fe1225 -vb=#1225fe"
  echo ""
  echo "  -s                  Show ANSI codes for used colors and exit"
  echo "  -h                  Print this help message"
}

load_theme_simple

while getopts "t:f:v:sh" arg; do
    case $arg in
    s) show_value="yes"                       ;;
    f) eval "$(cat "$OPTARG" | parse_theme)"  ;;
    v) eval "$(echo "$OPTARG" | parse_theme)" ;;
    t)
      case "$OPTARG" in
        "loreaccurate") load_theme_loreaccurate ;;
        "darklynx") load_theme_darklynx ;;
        "simple") load_theme_simple ;;
        "edge") load_theme_edge ;;
        *)
          echo 'Available themes: simple, loreaccurate, darklynx, edge' >&2
          exit 1
          ;;
      esac
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

[ -n "$show_value" ] && printf \
  "$R# R='%s'\n$O# O='%s'\n$Y# Y='%s'\n$G# G='%s'\n$C# C='%s'\n$B# B='%s'\n$M# M='%s'\n$RESET" \
  "$R" "$O" "$Y" "$G" "$C" "$B" "$M" \
  && exit

mode="${1:-"$DEFAULT_MODE"}"
case "$mode" in
  't'|'tiny')   maybe_dog || tiny   ;;
  's'|'small')  maybe_dog || small  ;;
  'm'|'medium') maybe_dog || medium ;;
  'l'|'large')  maybe_dog || large  ;;
  'd'|'dog')    dog_rand            ;;
  *)
    print_usage >&2
    exit 1
    ;;
esac
