hl.window_rule({
    match = { title = "<floating>" },
    float = true,
    size  = { "monitor_w*0.8", "monitor_h*0.8" },
})

hl.window_rule({
    match = { class = "^(blueman-manager)$" },
    float = true,
    size  = { "monitor_w*0.8", "monitor_h*0.8" },
})

hl.window_rule({
    match = { class = "^(nm-connection-editor)$" },
    float = true,
    size  = { "monitor_w*0.8", "monitor_h*0.8" },
})

hl.window_rule({
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    float = true,
    size  = { "monitor_w*0.8", "monitor_h*0.8" },
})

hl.window_rule({
    match = { class = "^(org.pipewire.Helvum)$" },
    float = true,
    size  = { "monitor_w*0.8", "monitor_h*0.8" },
})

-- Krita
hl.window_rule({
    match  = { title = "^(Saving As — Krita)$" },
    center = true,
    size   = { "monitor_w*0.7", "monitor_h*0.7" },
})

-- Ardour
hl.window_rule({
    match  = { class = "^(Ardour-[\\d+.]+)$", title = "^(Session Setup)$" },
    center = true,
})

hl.window_rule({
    match  = { class = "^(Ardour(-[\\d+.]+)?)$", title = "^.*(Helm|Calf|ACE|Select|SF2).*$" },
    center = true,
})

hl.window_rule({
    match = { class = "^(Ardour-[\\d+.]+)$", title = "^(Select|SF2).*$" },
    size  = { "monitor_w*0.5", "monitor_h*0.5" },
})
