-- Potat0Mac — ASUS ROG Strix G16 G614PH, Ryzen 9 + RTX 5050.
-- Selected by the machine hostname; hyprdodz is the username.
return {
    monitors = {
        { output = "eDP-1", mode = "1920x1200@165", position = "auto", scale = 1 },
        { output = "", mode = "preferred", position = "auto", scale = 1 },
    },
    -- Automatic selection currently works for the AMD/NVIDIA hybrid GPUs.
    gpu = {},
    env = {},
    -- The shared US/Arabic keyboard and touchpad settings already fit this laptop.
    input = {},
    apps = {},
    devices = {},
}
