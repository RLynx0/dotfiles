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
    width = monitor.width / monitor.scale - reserved.left - reserved.right - gaps.left - gaps.right - 2 * border,
    height = monitor.height / monitor.scale - reserved.top - reserved.bottom - gaps.top - gaps.bottom - 2 * border,
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
  dock = DEFAULT_DOCK or 'ur',
  width = DEFAULT_WIDTH or '40%',
  height = DEFAULT_HEIGHT or '100%',
}
local config = {
  dock = DOCK or default.dock,
  width = WIDTH or default.width,
  height = HEIGHT or default.height,
  workspace = WORKSPACE or 'quick--cmd',
  clean_restore = CLEAN_RESTORE,
}
local last = {
  literal = {
    dock = LAST_DOCK or default.dock,
    width = LAST_WIDTH or default.width,
    height = LAST_HEIGHT or default.height,
  },
  resolved = {
    dock = LAST_RESOLVED_DOCK or default.dock,
    width = LAST_RESOLVED_WIDTH or default.width,
    height = LAST_RESOLVED_HEIGHT or default.height,
  },
  index = {
    dock = tonumber(LAST_DOCK_INDEX) or 1,
    width = tonumber(LAST_WIDTH_INDEX) or 1,
    height = tonumber(LAST_HEIGHT_INDEX) or 1,
  },
}
setup_window(config, default, last)
