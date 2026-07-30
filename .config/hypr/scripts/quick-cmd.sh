#!/usr/bin/env bash

#  ██████╗ ██╗   ██╗██╗ ██████╗██╗  ██╗     ██████╗███╗   ███╗██████╗  #
# ██╔═══██╗██║   ██║██║██╔════╝██║ ██╔╝    ██╔════╝████╗ ████║██╔══██╗ #
# ██║   ██║██║   ██║██║██║     █████╔╝     ██║     ██╔████╔██║██║  ██║ #
# ██║▄▄ ██║██║   ██║██║██║     ██╔═██╗     ██║     ██║╚██╔╝██║██║  ██║ #
# ╚██████╔╝╚██████╔╝██║╚██████╗██║  ██╗    ╚██████╗██║ ╚═╝ ██║██████╔╝ #
#  ╚══▀▀═╝  ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝╚═╝     ╚═╝╚═════╝  #
#                 ___        ___ _                  __                 #
#                | _ )_  _  | _ \ |  _  _ _ _ __ __/  \                #
#                | _ \ || | |   / |_| || | ' \\ \ / () |               #
#                |___/\_, | |_|_\____\_, |_||_/_\_\\__/                #
#                     |__/           |__/                              #


set -uo pipefail

readonly DEFAULT_HEIGHT='100%'
readonly DEFAULT_WIDTH='40%'
readonly DEFAULT_DOCK='ur'

TERMINAL="${TERMINAL:-"kitty"}"
HEIGHT="${HEIGHT:-"$DEFAULT_HEIGHT"}"
WIDTH="${WIDTH:-"$DEFAULT_WIDTH"}"
DOCK="${DOCK:-"$DEFAULT_DOCK"}"
C_IND_H=0; C_IND_W=0; C_IND_D=0
CLEAN_RESTORE='false'; FORCE_FOCUS=''

function show_help {
  echo "Open, toggle and position a terminal window in a special hyprland workspace."
  printf "\nUsage: $(basename $0) [OPTIONS] [COMMAND]\n"
  printf "\nArguments:\n"
  echo "  [COMMAND]  Command to execute in the terminal."
  printf "\nOptions:\n"
  echo "  -H <HEIGHT>     Height of the window. Either N pixels or P% percentage.        Default: $DEFAULT_HEIGHT"
  echo "  -W <WIDTH>      Width of the window. Either N pixels or P% percentage.         Default: $DEFAULT_WIDTH"
  echo "  -d <DOCK>       List of characters used to dock the terminal.                  Default: $DEFAULT_DOCK"
  echo "  -c <CMD_CLASS>  Window class name used to identify the terminal.               Default: quick-<COMMAND>-<TERMINAL>"
  echo "  -w <WORKSPACE>  Name of the special workspace the terminal will be opened in.  Default: quick-<COMMAND>-<TERMINAL>"
  echo "  -t <TERMINAL>   Use a specific terminal.                                       Default: kitty"
  echo "  -f              Force focusing the window, even if it's already focused."
  echo "  -r              Restore previous HEIGHT, WIDTH and DOCK."
  echo "  -h              Print this help message and exit."
  printf "\nNotes:\n"
  echo "  HEIGHT, WIDTH and DOCK support special syntax."
  echo "  Setting their value to '$' will restore the previously used value."
  echo "  If this is not found, the value will fall back to its respective default."
  echo "  You can also pass these options multiple values delimited with ','."
  echo "  The script will cycle through these values on each execution."
  echo "  Finally, '-' is a shorthand for the default value."
  echo "  This may be useful when using the cycle feature."
}

while getopts "H:W:d:c:w:t:frh" arg; do
    case $arg in
    H) HEIGHT="$(tr -d ' ' <<<"$OPTARG")" ;;
    W) WIDTH="$(tr -d ' ' <<<"$OPTARG")" ;;
    d) DOCK="$(tr -d ' ' <<<"$OPTARG")" ;;
    c) CMD_CLASS="$OPTARG" ;;
    w) WORKSPACE="$OPTARG" ;;
    t) TERMINAL="$OPTARG" ;;
    f) FORCE_FOCUS='1' ;;
    r) HEIGHT='$'; WIDTH='$'; DOCK='$'; CLEAN_RESTORE='true' ;;
    h) show_help; exit ;;
    *)
      echo "Use the -h flag for usage." >&2
      exit 1
    esac
done
shift $(($OPTIND-1))

CMD_PROGRAM="${1:-""}"
CACHE_DIR="${XDG_CACHE_HOME:-"$HOME/.cache"}/quick-cmd"
CTX_FILE="$CACHE_DIR/quick-$CMD_PROGRAM-$TERMINAL.ctx"
CMD_CLASS="${CMD_CLASS:-"quick-$CMD_PROGRAM-$TERMINAL"}"
WORKSPACE="${WORKSPACE:-"quick-$CMD_PROGRAM-$TERMINAL"}"

function check_command {
  command -v "$1" &>/dev/null || {
    echo "ERROR: Required program '$1' not found in PATH"
    exit 1
  }
}

[ -z "$CMD_PROGRAM" ] || check_command "$CMD_PROGRAM"
check_command "$TERMINAL"
check_command hyprctl

# Loads variables LAST_DOCK, LAST_WIDTH, ...
source "$CTX_FILE" 2> /dev/null

function setup {
  hyprctl repl "
    local function resolve_percentage(string_value, value_full)
      local percent = string_value:match('^(%-?[%d%.]+)%%')
      if (percent) then return ((tonumber(percent) or 100) / 100) * value_full end
      return tonumber(string_value) or value_full
    end

    local function resolve_value(literal_value, last_literal, last_index, default, last_resolved)
      local parts = {}
      for part in literal_value:gmatch('([^,]+)') do table.insert(parts, part) end
      local index = 1 + (last_index % #parts)
      if literal_value ~= last_literal then index = 1 end
      local value = parts[index]
      if value == '-' then value = default end
      if value == '$' then value = last_resolved end
      return { value = value or default, index = index }
    end

    local function resolve_dock_pos(dock_string, space, dims)
      local x_l = space.x
      local x_r = space.x + space.width - dims.x
      local x_c = space.x + (space.width - dims.x) / 2
      local y_t = space.y
      local y_b = space.y + space.height - dims.y
      local y_c = space.y + (space.height - dims.y) / 2
      local x = x_c
      local y = y_c

      for c in dock_string:gmatch('.') do
        if c == 'c' then x = x_c; y = y_c
        elseif c == 'u' or c == 't' then y = y_t
        elseif c == 'd' or c == 'b' then y = y_b
        elseif c == 'l' then x = x_l
        elseif c == 'r' then x = x_r
        end
      end

      return { x = x, y = y }
    end

    local function setup_window(config, default, last)
      local monitor = hl.get_monitor_at_cursor()
      local reserved = monitor.reserved
      local gaps = hl.get_config('general.gaps_out')
      local border = hl.get_config('general.border_size')
      local space = {
        x = monitor.position.x + reserved.left + gaps.left + border,
        y = monitor.position.y + reserved.top + gaps.bottom + border,
        width = monitor.width - reserved.left - reserved.right - gaps.left - gaps.right - 2 * border,
        height = monitor.height - reserved.top - reserved.bottom - gaps.top - gaps.bottom - 2 * border,
      }

      local resolved_dock = resolve_value(config.dock, last.literal.dock, last.index.dock, default.dock, last.resolved.dock)
      local resolved_width = resolve_value(config.width, last.literal.width, last.index.width, default.width, last.resolved.width)
      local resolved_height = resolve_value(config.height, last.literal.height, last.index.height, default.height, last.resolved.height)
      local dims = {
        x = resolve_percentage(resolved_width.value, space.width),
        y = resolve_percentage(resolved_height.value, space.height),
      }

      local pos = resolve_dock_pos(resolved_dock.value, space, dims)
      hl.dispatch(hl.dsp.window.move({ workspace = 'special:' .. config.workspace }))
      if not hl.get_active_window().floating then hl.dispatch(hl.dsp.window.float()) end
      hl.dispatch(hl.dsp.window.resize({ x = dims.x, y = dims.y, relative = false }))
      hl.dispatch(hl.dsp.window.move({ x = pos.x, y = pos.y, relative = false }))

      print('LAST_RESOLVED_DOCK=\"'   .. resolved_dock.value                                                   .. '\"')
      print('LAST_RESOLVED_WIDTH=\"'  .. resolved_width.value                                                  .. '\"')
      print('LAST_RESOLVED_HEIGHT=\"' .. resolved_height.value                                                 .. '\"')
      print('LAST_DOCK=\"'            .. (config.clean_restore and last.literal.dock or config.dock)           .. '\"')
      print('LAST_WIDTH=\"'           .. (config.clean_restore and last.literal.width or config.width)         .. '\"')
      print('LAST_HEIGHT=\"'          .. (config.clean_restore and last.literal.height or config.height)       .. '\"')
      print('LAST_DOCK_INDEX=\"'      .. (config.clean_restore and last.index.dock or resolved_dock.index)     .. '\"')
      print('LAST_WIDTH_INDEX=\"'     .. (config.clean_restore and last.index.width or resolved_width.index)   .. '\"')
      print('LAST_HEIGHT_INDEX=\"'    .. (config.clean_restore and last.index.height or resolved_height.index) .. '\"')
    end

    local default = {
      dock = '$DEFAULT_DOCK' or 'ur',
      width = '$DEFAULT_WIDTH' or '40%',
      height = '$DEFAULT_HEIGHT' or '100%',
    }
    local config = {
      dock = '$DOCK' or default.dock,
      width = '$WIDTH' or default.width,
      height = '$HEIGHT' or default.height,
      workspace = '$WORKSPACE' or 'quick--cmd',
      clean_restore = ${CLEAN_RESTORE:-"false"},
    }
    local last = {
      literal = {
        dock = '${LAST_DOCK:-""}' or default.dock,
        width = '${LAST_WIDTH:-""}' or default.width,
        height = '${LAST_HEIGHT:-""}' or default.height,
      },
      resolved = {
        dock = '${LAST_RESOLVED_DOCK:-""}' or default.dock,
        width = '${LAST_RESOLVED_WIDTH:-""}' or default.width,
        height = '${LAST_RESOLVED_HEIGHT:-""}' or default.height,
      },
      index = {
        dock = tonumber('${LAST_DOCK_INDEX:-""}') or 1,
        width = tonumber('${LAST_WIDTH_INDEX:-""}') or 1,
        height = tonumber('${LAST_HEIGHT_INDEX:-""}') or 1,
      },
    }
    setup_window(config, default, last)
  " > "$CTX_FILE"
}

function already_open {
  hyprctl repl 'for _, w in pairs(hl.get_windows()) do print(w.class) end' \
  | grep -E "^$CMD_CLASS$"
}

function focused {
  test "$(hyprctl repl 'hl.get_active_window().class')" = "$CMD_CLASS"
}

function in_ws {
  test "$(hyprctl repl 'hl.get_active_window().workspace.name')" = "special:$WORKSPACE"
}

function open_cmd {
  hyprctl eval 'hl.window_rule({ name = "float-'"$CMD_CLASS"'", match = { class = "'"$CMD_CLASS"'" }, float = true })'
  "$TERMINAL" --class "$CMD_CLASS" "$CMD_PROGRAM" &
  while true; do already_open && break; sleep 0.05; done
}

function toggle_view {
  in_ws && hyprctl dispatch 'hl.dsp.workspace.toggle_special("'"$WORKSPACE"'")' \
  || hyprctl dispatch 'hl.dsp.focus({ window = "class:'"$CMD_CLASS"'" })'
}

already_open || open_cmd                        > /dev/null
focused && [ -n "$FORCE_FOCUS" ] || toggle_view > /dev/null
focused && setup                                > /dev/null
exit 0
