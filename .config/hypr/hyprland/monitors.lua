local function enableLaptopMonitor()
    hl.monitor({ output = "desc:BOE 0x095F", mode = "preferred", position = "0x0", scale = "auto", disabled = false })
end

local function disableLaptopMonitor()
    hl.monitor({ output = "desc:BOE 0x095F", disabled = true })
end

enableLaptopMonitor()

hl.monitor({ output = "desc:AOC 27G2G8 PWPP6JA023813",           mode = "1920x1080", position = "-1920x-380",  scale = "auto" })
hl.monitor({ output = "desc:Lenovo Group Limited P27h-30 V30C0318",   mode = "1920x1080", position = "0x0",        scale = "auto" })
hl.monitor({ output = "desc:Lenovo Group Limited TIO24Gen4T V3084BPW", mode = "1920x1080", position = "-410x-1080", scale = "auto" })
hl.monitor({ output = "Virtual-1",                                mode = "1920x1080", position = "0x0",        scale = 1.0   })

hl.workspace_rule({ workspace = "1", monitor = "desc:AOC 27G2G8 PWPP6JA023813", default = true })

hl.bind("switch:off:Lid Switch", function() enableLaptopMonitor()  end, { locked = true })
hl.bind("switch:on:Lid Switch",  function() disableLaptopMonitor() end, { locked = true })

return { enableLaptopMonitor = enableLaptopMonitor, disableLaptopMonitor = disableLaptopMonitor }
