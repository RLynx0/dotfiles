hl.config({
    general = {
        gaps_in    = 6,
        gaps_out   = 12,
        border_size = 3,

        col = {
            active_border   = { colors = { "rgba(ff44eeee)", "rgba(44eeffee)" } },
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",

        allow_tearing = false,
    },

    decoration = {
        rounding = 8,

        blur = {
            enabled = true,
            size    = 3,
            passes  = 2,
        },

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
    },
})

hl.curve("steep",  { type = "bezier", points = { { 0.05, 0.8 }, { 0.2, 1.05 } } })
hl.curve("linear", { type = "bezier", points = { { 0.0,  0.0 }, { 1.0, 1.0  } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 6,   bezier = "steep"   })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 6,   bezier = "linear",  style = "popin 30%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10,  bezier = "default"  })
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "linear",  style = "loop" })
hl.animation({ leaf = "fade",        enabled = true, speed = 6,   bezier = "default"  })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,   bezier = "default"  })
