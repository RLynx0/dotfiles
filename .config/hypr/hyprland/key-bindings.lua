local terminal    = "kitty"
local fileManager = "thunar"
local browser     = "librewolf"

local menu          = "wofi --insensitive --allow-images --show drun"
local menuToggle    = "pkill wofi || " .. menu
local clipboard     = "~/.config/scripts/clipboard.sh"
local clipboardDelete = "~/.config/scripts/clipboard.sh delete"
local emojiSelectorType = "pkill wofi || rofimoji --action type"
local emojiSelectorCopy = "pkill wofi || rofimoji --action copy"
local ws_swap       = "~/.config/hypr/scripts/ws-swap.sh"
local quick_cmd     = "~/.config/hypr/scripts/quick-cmd.sh"
local quick_cava    = quick_cmd .. " -H 65% -W 63% -d c cava"

local startWaybar   = "~/.config/waybar/start.sh"
local lock          = "hyprlock"
local laptopBrightnessUp   = "~/.config/scripts/lumen.sh up 5"
local laptopBrightnessDown = "~/.config/scripts/lumen.sh down 5"
local gammashift    = "~/.config/scripts/gammashift.sh"
local nightMode     = gammashift .. " Temperature 4200 & " .. gammashift .. " Brightness 0.5 & " .. gammashift .. " Gamma 1.2"
local resetGammarelay = gammashift .. " Temperature 6500 & " .. gammashift .. " Brightness 1.0 & " .. gammashift .. " Gamma 1.0"
local brightnessUp   = gammashift .. " Brightness +0.05 0.01"
local brightnessDown = gammashift .. " Brightness -0.05 0.01"
local temperatureUp  = gammashift .. " Temperature +250 0.01"
local temperatureDown = gammashift .. " Temperature -250 0.01"
local volumeUp       = "~/.config/scripts/sonorum.sh up 5"
local volumeDown     = "~/.config/scripts/sonorum.sh down 5"
local volumeUpFine   = "~/.config/scripts/sonorum.sh up 1"
local volumeDownFine = "~/.config/scripts/sonorum.sh down 1"
local volumeUpBroad  = "~/.config/scripts/sonorum.sh up 25"
local volumeDownBroad = "~/.config/scripts/sonorum.sh down 25"
local volumeMute     = "~/.config/scripts/sonorum.sh mute"
local hyprZoom       = "~/.config/hypr/scripts/zoom.sh"
local panicForced    = "~/.config/hypr/scripts/panic/panic.sh -ps 1"
local panicSwitch    = "~/.config/hypr/scripts/panic/panic.sh -s 1"
local notificationsDismiss = "makoctl dismiss --all"
local notificationsRestore = "makoctl restore"
local colorPicker    = 'notify-send "$(hyprpicker -ar)" "Copied Color to Clipboard!"'
local panicLock      = panicForced .. ";" .. lock .. ";waitpid $(pidof swaylock);" .. panicSwitch
-- NOTE: exec-once-again.sh parses the old .conf format; update the script to work with Lua.
local execOnceAgain  = "~/.config/hypr/scripts/exec-once-again.sh hyprland/autostart.conf"
local hyprCoffee     = "~/.config/hypr/scripts/hypr-coffee"

local screenshotSavePath   = "~/Personal/Pictures/screenshots/$(date '+%F_%T_%N').png"
local copyScreenshotArea   = "grimblast --notify --freeze copy area"
local copyScreenshotWindow = "grimblast --notify copy output"
local saveScreenshotArea   = "grimblast --notify --freeze save area " .. screenshotSavePath
local saveScreenshotWindow = "grimblast --notify save output " .. screenshotSavePath

local appPath       = os.getenv("HOME") .. "/.local/share/applications"
local appLauncher   = "dex"
local youtube       = appLauncher .. " " .. appPath .. "/home-made/YouTube.desktop"
local reddit        = appLauncher .. " " .. appPath .. "/home-made/Reddit.desktop"
local whatsApp      = appLauncher .. " " .. appPath .. "/home-made/WhatsApp.desktop"

local bluetoothControllerMac = "98:B6:E8:7A:7C:31"
local reconnectController    = "bluetoothctl disconnect " .. bluetoothControllerMac .. " && bluetoothctl connect " .. bluetoothControllerMac

local WS_browser   = "~/.config/scripts/librewolf-workspace.sh"
local URL_reddit   = "https://www.reddit.com"
local URL_whatsapp = "https://web.whatsapp.com"
local URL_instagram = "https://www.instagram.com"
local URL_bluesky  = "https://bsky.app"
local URL_telegram = "https://web.telegram.org"


-- Modifiers
local mainMod = "SUPER"
local moveMod = "SUPER + SHIFT"
local maltMod = "SUPER + ALT"
local ctrlMod = "SUPER + CTRL"
local caltMod = "SUPER + CTRL + ALT"
local lynxMod = "CTRL + ALT + SHIFT"


-- Laptop monitor enable/disable (mirrored from monitors.lua for direct Lua dispatch)
local function enableLaptopMonitor()
    hl.monitor({ output = "desc:BOE 0x095F", mode = "preferred", position = "0x0", scale = "auto", disabled = false })
end
local function disableLaptopMonitor()
    hl.monitor({ output = "desc:BOE 0x095F", disabled = true })
end


-- System Controls
hl.bind(mainMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd(laptopBrightnessUp),   { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd(laptopBrightnessDown), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",                hl.dsp.exec_cmd(laptopBrightnessUp),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",              hl.dsp.exec_cmd(laptopBrightnessDown), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume",               hl.dsp.exec_cmd(volumeUp),             { repeating = true })
hl.bind("XF86AudioLowerVolume",               hl.dsp.exec_cmd(volumeDown),           { repeating = true })
hl.bind("CTRL + XF86AudioRaiseVolume",        hl.dsp.exec_cmd(volumeUpBroad),        { repeating = true })
hl.bind("CTRL + XF86AudioLowerVolume",        hl.dsp.exec_cmd(volumeDownBroad),      { repeating = true })
hl.bind("SHIFT + XF86AudioRaiseVolume",       hl.dsp.exec_cmd(volumeUpFine),         { repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume",       hl.dsp.exec_cmd(volumeDownFine),       { repeating = true })
hl.bind("XF86AudioMute",                      hl.dsp.exec_cmd(volumeMute))
hl.bind("XF86AudioPlay",                      hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev",                      hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioNext",                      hl.dsp.exec_cmd("playerctl next"))
hl.bind(ctrlMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd(brightnessUp),   { repeating = true })
hl.bind(ctrlMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd(brightnessDown), { repeating = true })
hl.bind(caltMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd(temperatureUp),  { repeating = true })
hl.bind(caltMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd(temperatureDown),{ repeating = true })
hl.bind(ctrlMod .. " + N", hl.dsp.exec_cmd(nightMode),          { locked = true })
hl.bind(ctrlMod .. " + M", hl.dsp.exec_cmd(resetGammarelay),    { locked = true })
hl.bind(ctrlMod .. " + S", hl.dsp.exec_cmd(copyScreenshotArea))
hl.bind(ctrlMod .. " + W", hl.dsp.exec_cmd(copyScreenshotWindow))
hl.bind(caltMod .. " + S", hl.dsp.exec_cmd(saveScreenshotArea))
hl.bind(caltMod .. " + W", hl.dsp.exec_cmd(saveScreenshotWindow))
hl.bind(ctrlMod .. " + C", hl.dsp.exec_cmd(clipboard))
hl.bind(caltMod .. " + C", hl.dsp.exec_cmd(clipboardDelete))
hl.bind(ctrlMod .. " + E", hl.dsp.exec_cmd(emojiSelectorType))
hl.bind(caltMod .. " + E", hl.dsp.exec_cmd(emojiSelectorCopy))
hl.bind(ctrlMod .. " + L", hl.dsp.exec_cmd(lock))
hl.bind(caltMod .. " + L", hl.dsp.exec_cmd(panicLock))
hl.bind(ctrlMod .. " + Q", hl.dsp.exec_cmd(colorPicker))
hl.bind(ctrlMod .. " + F", hl.dsp.exec_cmd("pkill easyeffects; easyeffects --gapplication-service; notify-send 'EasyEffects Restarted!'"))
hl.bind(ctrlMod .. " + B", hl.dsp.exec_cmd(startWaybar))
hl.bind(ctrlMod .. " + Z", hl.dsp.exec_cmd(hyprZoom))
hl.bind(ctrlMod .. " + H", hl.dsp.exec_cmd("pkill hyprpaper; hyprpaper & disown"))
hl.bind(ctrlMod .. " + P", function() disableLaptopMonitor() end)
hl.bind(caltMod .. " + P", function() enableLaptopMonitor()  end)
hl.bind(ctrlMod .. " + R", hl.dsp.exec_cmd(execOnceAgain))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(hyprCoffee))
hl.bind(caltMod .. " + B", hl.dsp.exec_cmd(reconnectController))

-- Hyprland Essential Controls
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("pkill wlogout || wlogout"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + Y", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(maltMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized"  }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(panicSwitch))
hl.bind(maltMod .. " + D", hl.dsp.exec_cmd(panicForced))

-- Essential app keybinds
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menuToggle))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

-- Convenient keybinds
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(notificationsDismiss))
hl.bind(maltMod .. " + N", hl.dsp.exec_cmd(notificationsRestore))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(quick_cmd .. " -r"))
hl.bind(moveMod .. " + X", hl.dsp.exec_cmd(quick_cmd .. " -fW -,70%,- -d r,c,l"))
hl.bind(ctrlMod .. " + X", hl.dsp.exec_cmd(quick_cmd .. " -fH 50% -d dr,ur,ul,dl"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(quick_cava))

-- Compatibility bindings
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal))
hl.bind("ALT + F4",       hl.dsp.window.close())

-- Commune
hl.bind(mainMod .. " + U", function()
    hl.dispatch(hl.dsp.exec_cmd(WS_browser .. " " .. URL_reddit .. " " .. URL_whatsapp .. " " .. URL_instagram .. " " .. URL_bluesky .. " " .. URL_telegram .. " & disown"))
    hl.dispatch(hl.dsp.exec_cmd("discord"))
    hl.dispatch(hl.dsp.exec_cmd("thunderbird"))
end)

-- Custom app keybinds
hl.bind(lynxMod .. " + A", hl.dsp.exec_cmd("uhk-agent"))
hl.bind(lynxMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(lynxMod .. " + D", hl.dsp.exec_cmd("discord"))
hl.bind(lynxMod .. " + E", hl.dsp.exec_cmd("thunderbird"))
hl.bind(lynxMod .. " + F", hl.dsp.exec_cmd("easyeffects"))
hl.bind(lynxMod .. " + G", hl.dsp.exec_cmd("godot"))
hl.bind(lynxMod .. " + M", hl.dsp.exec_cmd("spotify"))
hl.bind(lynxMod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(lynxMod .. " + S", hl.dsp.exec_cmd("steam"))
hl.bind(lynxMod .. " + T", hl.dsp.exec_cmd("torbrowser-launcher"))
hl.bind(lynxMod .. " + V", hl.dsp.exec_cmd("virt-manager"))
hl.bind(lynxMod .. " + X", hl.dsp.exec_cmd("keepassxc"))
hl.bind(lynxMod .. " + R", hl.dsp.exec_cmd(reddit))
hl.bind(lynxMod .. " + W", hl.dsp.exec_cmd(whatsApp))
hl.bind(lynxMod .. " + Y", hl.dsp.exec_cmd(youtube))

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move active window with moveMod + hjkl
hl.bind(moveMod .. " + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(moveMod .. " + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(moveMod .. " + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(moveMod .. " + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(moveMod .. " + C", hl.dsp.window.center())

-- Move active window with moveMod + arrow keys
hl.bind(moveMod .. " + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(moveMod .. " + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(moveMod .. " + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(moveMod .. " + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize active window with maltMod + hjkl
hl.bind(maltMod .. " + L", hl.dsp.window.resize({ x =  24, y =   0, relative = true }), { repeating = true })
hl.bind(maltMod .. " + H", hl.dsp.window.resize({ x = -24, y =   0, relative = true }), { repeating = true })
hl.bind(maltMod .. " + K", hl.dsp.window.resize({ x =   0, y = -24, relative = true }), { repeating = true })
hl.bind(maltMod .. " + J", hl.dsp.window.resize({ x =   0, y =  24, relative = true }), { repeating = true })

-- Resize active window with maltMod + arrow keys
hl.bind(maltMod .. " + right", hl.dsp.window.resize({ x =  24, y =   0, relative = true }), { repeating = true })
hl.bind(maltMod .. " + left",  hl.dsp.window.resize({ x = -24, y =   0, relative = true }), { repeating = true })
hl.bind(maltMod .. " + up",    hl.dsp.window.resize({ x =   0, y = -24, relative = true }), { repeating = true })
hl.bind(maltMod .. " + down",  hl.dsp.window.resize({ x =   0, y =  24, relative = true }), { repeating = true })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with moveMod + [0-9]
-- Move active window silently with maltMod + [0-9]
-- Swap contents of a workspace with ctrlMod + [0-9]
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(moveMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind(maltMod .. " + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
    hl.bind(ctrlMod .. " + " .. key, hl.dsp.exec_cmd(ws_swap .. " " .. i))
end

-- Special Workspaces
hl.bind(mainMod .. " + A", hl.dsp.workspace.toggle_special("magic"))
hl.bind(moveMod .. " + A", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(maltMod .. " + A", hl.dsp.window.move({ workspace = "special:magic", follow = false }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("shadowRealm"))
hl.bind(moveMod .. " + S", hl.dsp.window.move({ workspace = "special:shadowRealm" }))
hl.bind(maltMod .. " + S", hl.dsp.window.move({ workspace = "special:shadowRealm", follow = false }))

-- Scroll through existing workspaces with mainMod + scroll / ,.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + PERIOD",     hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + COMMA",      hl.dsp.focus({ workspace = "e-1" }))
