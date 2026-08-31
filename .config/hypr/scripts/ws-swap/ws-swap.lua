-- This script is meant to be executed with `hyprctl repl`
-- The following variables must be set beforehand:
--   TARGET_WS

local function ws_contents(ws_name)
  local windows = {}
  for _,window in pairs(hl.get_windows()) do
    if window.workspace.name == ws_name then
      table.insert(windows, window)
    end
  end
  return windows
end

local function swap(target_ws_name)
  if target_ws_name == '' then
    print("Provide a target workspace")
    return
  end

  local current_ws = hl.get_active_workspace()
  local current_ws_name = current_ws.name
  if current_ws_name == target_ws_name then
    print("Current and target workspace are the same")
    return
  end

  print("Swapping "..current_ws_name.." with "..target_ws_name)
  local current_contents = ws_contents(current_ws_name)
  local target_contents = ws_contents(target_ws_name)
  local switch_to_target = false

  for _,w in pairs(current_contents) do
    print("Moving "..w.address.." ("..w.class..") ["..current_ws_name.." -> "..target_ws_name.."]")
    hl.dispatch(hl.dsp.window.move({
      window = "address:"..w.address,
      workspace = target_ws_name,
    }))
    switch_to_target = true
  end
  for _,w in pairs(target_contents) do
    print("Moving "..w.address.." ("..w.class..") ["..target_ws_name.." -> "..current_ws_name.."]")
    hl.dispatch(hl.dsp.window.move({
      window = "address:"..w.address,
      workspace = current_ws_name,
    }))
  end

  if not switch_to_target then return end
  hl.dispatch(hl.dsp.focus({
    workspace = target_ws_name,
  }))
end

swap(TARGET_WS or '')
