return {
    monitors = {
        -- "preferred" picks the panel's native mode -- no need to hardcode a
        -- resolution/refresh rate you'd have to look up per machine.
        { output = "eDP-1", mode = "preferred", position = "auto", scale = 1 },
        -- Catch-all: any docked/external display, auto-placed to the right.
        { output = "",      mode = "preferred", position = "auto", scale = 1 },
    },
    apps = {},
    devices = {
        { name = "synps/2-synaptics-touchpad", sensitivity = 0.2 },
    },
}
