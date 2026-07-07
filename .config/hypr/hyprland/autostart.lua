-- NOTE: The exec-once-again.sh script parses exec-once lines from the old
-- .conf format. It will need to be updated to work with this Lua config.
-- The #R: comments below are kept for reference until then.

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("easyeffects --gapplication-service")  -- #R: kill, exec
    hl.exec_cmd("wl-gammarelay-rs")                    -- #R: kill, exec
    hl.exec_cmd("~/.config/waybar/start.sh")           -- #R: exec
    hl.exec_cmd("waypaper --restore")                  -- #R: exec
    hl.exec_cmd("hypridle")                            -- #R: kill, exec
    hl.exec_cmd("fcitx5 -d")                           -- #R: kill, exec
    hl.exec_cmd("mako")                                -- #R: kill, exec
    hl.exec_cmd("sleep 1; setxkbmap de")              -- #R: exec
end)
