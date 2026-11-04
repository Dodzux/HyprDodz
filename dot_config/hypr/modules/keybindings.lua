-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
-- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
--
-- MODULE 9: KEYBINDINGS
-- Keyboard shortcuts and input handling
-- See: https://wiki.hypr.land/Configuring/Basics/Binds/
-- ═══════════════════════════════════════════════════════════════

local vars = require("modules.variables")
local m    = vars.mainMod

-- ▓▒░ BIND HELPER + CHEATSHEET REGISTRY
-- Every bind in this file goes through bind(), which is hl.bind() plus one
-- thing: it records the action under its modmask + key, so the quickshell
-- cheatsheet (SUPER+H) can run a bind it lists:
--   hyprctl eval 'cheatsheet.run(64, "Q")'
-- `hyprctl binds -j` shows Lua binds only as dispatcher "__lua" with an opaque
-- id, so without this the cheatsheet could list binds but never run one.
-- `cheatsheet` is a global on purpose: `hyprctl eval` runs in this Lua state
-- and can only reach globals. It is rebuilt on every config reload.
--
-- Every description is "Category: Action". The cheatsheet splits it into its
-- left-rail category and the row title, so keep that shape when adding binds.
-- Binds whose descriptions differ only by a trailing direction (left/right/
-- up/down) or number collapse into one row there ("Focus window ←→↑↓").
local MOD_MASKS = { SHIFT = 1, CAPS = 2, CTRL = 4, CONTROL = 4, ALT = 8,
                    MOD2 = 16, MOD3 = 32, SUPER = 64, MOD4 = 64, MOD5 = 128 }

cheatsheet = { actions = {} }

function cheatsheet.run(mask, key)
    local action = cheatsheet.actions[mask .. ":" .. key]
    if action then hl.dispatch(action) end
end

local lock_safe_binds = {}

local function bind(keys, action, opts)
    local parts = {}
    for part in keys:gmatch("[^+]+") do
        parts[#parts + 1] = part:match("^%s*(.-)%s*$")
    end
    local mask = 0
    for i = 1, #parts - 1 do
        mask = mask + (MOD_MASKS[parts[i]:upper()] or 0)
    end
    cheatsheet.actions[mask .. ":" .. parts[#parts]] = action
    if opts and opts.locked then
        lock_safe_binds[#lock_safe_binds + 1] = { keys = keys, action = action, opts = opts }
    end
    return hl.bind(keys, action, opts)
end

-- ▓▒░ APPLICATION LAUNCHER BINDINGS
bind(m .. " + T", hl.dsp.exec_cmd(vars.terminal), { description = "Apps: Terminal (kitty)" })
bind(m .. " + E", hl.dsp.exec_cmd(vars.fileManager), { description = "Apps: File manager (yazi)" })
bind(m .. " + B", hl.dsp.exec_cmd(vars.browser), { description = "Apps: Browser (Brave Origin)" })
bind(m .. " + C", hl.dsp.exec_cmd(vars.terminal_editor), { description = "Apps: Editor (Neovim)" })     -- kitty -e nvim (NvChad)
bind(m .. " + O", hl.dsp.exec_cmd(vars.notingApp), { description = "Apps: Notes (Obsidian)" })
bind(m .. " + D", hl.dsp.exec_cmd(vars.discord), { description = "Apps: Discord" })
bind(m .. " + U", hl.dsp.exec_cmd(vars.updater), { description = "System: Update system (pacman -Syu)" })              -- CachyOS system updater
if vars.codex then
    bind(m .. " + X", hl.dsp.exec_cmd(vars.codex), { description = "Apps: Codex" })
end
if vars.thePlan then   -- nil unless installed (modules/variables.lua)
    bind(m .. " + Y", hl.dsp.exec_cmd(vars.thePlan), { description = "Apps: The Plan" })
end

if vars.herdr then
    bind(m .. " + R", hl.dsp.exec_cmd(vars.herdr), { description = "Apps: Herdr" })
end

-- ▓▒░ QUICKSHELL PANEL TRIGGERS
-- These use Hyprland's global_shortcuts protocol to signal quickshell panels.
-- The panels register matching appid+name pairs via GlobalShortcut in QML.
-- See: https://wiki.hypr.land/Configuring/Basics/Binds/#global-shortcuts
bind(m .. " + A",         hl.dsp.global("quickshell:toggle-launcher"), { description = "Panels: App launcher" })
bind(m .. " + Space",     hl.dsp.global("quickshell:toggle-wallpaper-selector"), { description = "Panels: Wallpaper selector" })
bind(m .. " + F",         hl.dsp.global("quickshell:focus-bar"), { description = "Panels: Focus the bar (keyboard navigation)" })
bind(m .. " + Backspace", hl.dsp.global("quickshell:toggle-power-menu"), { description = "Panels: Power menu" })
bind("Print",             hl.dsp.global("quickshell:toggle-screenshot"), { description = "Capture: Screenshot panel (copy / save)" })
bind(m .. " + H",         hl.dsp.global("quickshell:toggle-shortcuts"), { description = "Panels: Keybind cheatsheet" })
bind(m .. " + comma",     hl.dsp.global("quickshell:toggle-notifications"), { description = "Panels: Notifications + Do Not Disturb" })
bind(m .. " + grave",     hl.dsp.global("quickshell:toggle-overview"), { description = "Panels: Window overview" })

-- ▓▒░ WINDOW MANAGEMENT
bind(m .. " + Q",             hl.dsp.window.close(), { description = "Windows: Close window" })
bind(m .. " + W",             hl.dsp.window.float({ action = "toggle" }), { description = "Windows: Toggle floating" })
bind(m .. " + P",             hl.dsp.window.pseudo(), { description = "Windows: Toggle pseudotile" })
bind(m .. " + J",             hl.dsp.layout("togglesplit"), { description = "Windows: Toggle split direction" })   -- dwindle.preserve_split needs this bind to matter
bind("ALT + SHIFT + Return",  hl.dsp.window.fullscreen({ mode = "fullscreen",  action = "toggle" }), { description = "Windows: Fullscreen" })
bind("ALT + Return",          hl.dsp.window.fullscreen({ mode = "maximized",   action = "toggle" }), { description = "Windows: Maximize" })

-- ▓▒░ WINDOW RESIZE (repeating)
bind(m .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }),  { repeating = true, description = "Windows: Resize window right" })
bind(m .. " + SHIFT + left",  hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true, description = "Windows: Resize window left" })
bind(m .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true, description = "Windows: Resize window up" })
bind(m .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 30, relative = true }),  { repeating = true, description = "Windows: Resize window down" })

-- ▓▒░ KEYBOARD LAYOUT SWITCHING
-- Cycles through input.kb_layout (modules/input.lua, per-host override in hosts/)
bind(m .. " + K", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"), { locked = true, description = "System: Switch keyboard layout" })

-- ▓▒░ CLIPBOARD MANAGEMENT
-- SUPER+V opens clipboard history via the quickshell ClipboardPanel
bind(m .. " + V",         hl.dsp.global("quickshell:toggle-clipboard"), { description = "Panels: Clipboard history" })
bind(m .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist wipe"), { description = "Panels: Wipe clipboard history" })

-- ▓▒░ SCREENSHOT BINDINGS
-- F11: Direct region capture → clipboard (fast, no UI)
-- Both paths stop on selection cancellation or capture failure and use a fresh
-- temporary image, so canceling never copies or annotates an old screenshot.
bind("F11", hl.dsp.exec_cmd(
    'sh "$HOME/.config/hypr/scripts/screenshot_region.sh" copy'
), { description = "Capture: Region to clipboard" })
-- F12: Region capture → Satty annotation → save & clipboard
bind("F12", hl.dsp.exec_cmd(
    'sh "$HOME/.config/hypr/scripts/screenshot_region.sh" annotate'
), { description = "Capture: Region to Satty (annotate + save)" })
-- SUPER+Print: close all windows first -- captures the desktop as the README
-- preview and pushes it (chezmoi scripts/showcase.sh)
bind(m .. " + Print", hl.dsp.exec_cmd('sh -c \'"$(chezmoi source-path)/scripts/showcase.sh"\''), { description = "Capture: Desktop showcase for the README" })
-- Print: Opens the quickshell ScreenshotPanel (Copy / Save / Save & Copy)
-- (handled by the global_shortcuts bind above)

-- ▓▒░ WINDOW FOCUS NAVIGATION
bind(m .. " + left",  hl.dsp.focus({ direction = "left"  }), { description = "Windows: Focus window left" })
bind(m .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Windows: Focus window right" })
bind(m .. " + up",    hl.dsp.focus({ direction = "up"    }), { description = "Windows: Focus window up" })
bind(m .. " + down",  hl.dsp.focus({ direction = "down"  }), { description = "Windows: Focus window down" })

-- ▓▒░ WORKSPACE SWITCHING & MOVE WINDOW TO WORKSPACE
for i = 1, 10 do
    local key = i % 10    -- 10 maps to key 0
    bind(m .. " + "           .. key, hl.dsp.focus({ workspace = i }),       { description = "Workspaces: Go to workspace " .. i })
    bind(m .. " + SHIFT + "   .. key, hl.dsp.window.move({ workspace = i }), { description = "Workspaces: Move window to workspace " .. i })
end

-- ▓▒░ SPECIAL WORKSPACES (SCRATCHPADS)
-- Drop-down terminal (SUPER+S)
bind(m .. " + S",         hl.dsp.workspace.toggle_special("terminal"), { description = "Workspaces: Scratchpad terminal" })
bind(m .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:terminal" }), { description = "Workspaces: Send window to scratchpad terminal" })
-- Notes / Obsidian (SUPER+N)
bind(m .. " + N",         hl.dsp.workspace.toggle_special("notes"), { description = "Workspaces: Scratchpad notes" })
bind(m .. " + SHIFT + N", hl.dsp.window.move({ workspace = "special:notes" }), { description = "Workspaces: Send window to scratchpad notes" })

-- ▓▒░ WORKSPACE CYCLING (scroll wheel + arrow key overrides)
bind(m .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Workspaces: Next workspace (scroll)" })
bind(m .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Workspaces: Previous workspace (scroll)" })

-- ▓▒░ MOUSE BINDINGS — drag and resize windows
bind(m .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Windows: Drag window" })
bind(m .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Windows: Resize window (drag)" })

-- ▓▒░ MULTIMEDIA & BRIGHTNESS (laptop function keys)
-- brightnessctl, playerctl and wpctl are installed on Potat0Mac.
bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Media: Volume up" })
bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Media: Volume down" })
bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, description = "Media: Mute output" })
bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, description = "Media: Mute microphone" })
bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -c backlight -n1 set 5%+ && qs ipc call brightness showBrightness"),                  { locked = true, repeating = true, description = "Media: Brightness up" })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -c backlight -n1 set 5%- && qs ipc call brightness showBrightness"),                  { locked = true, repeating = true, description = "Media: Brightness down" })

-- Laptop-specific command is supplied by hosts/Potat0Mac.lua.
if vars.performanceMode then
    bind("XF86Launch4", hl.dsp.exec_cmd(vars.performanceMode), { description = "System: Cycle performance mode (fan key)" })
end

-- The ASUS driver also handles the physical key. The helper persists and
-- reapplies our choice on release, keeping it consistent after a login restore.
if vars.fnLock then
    bind("XF86Fn_Esc", hl.dsp.exec_cmd(vars.fnLock .. " toggle"), { release = true, locked = true, description = "System: Toggle Fn key mode" })
end

-- ▓▒░ MEDIA CONTROL
bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Media: Next track" })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media: Play / pause" })
bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media: Play / pause" })
bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Media: Previous track" })

-- ▓▒░ WALLPAPER TRANSITION (SUPER + SHIFT + W)
bind(m .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/awww_transition.sh"), { repeating = true, description = "System: Random wallpaper" })

-- ▓▒░ OPENRGB COLOR PICKER (SUPER + SHIFT + P)
bind(m .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/pick_rgb.fish"), { description = "System: Pick an OpenRGB colour from the screen" })

-- ▓▒░ SESSION LOCK
-- Emits logind's Lock signal rather than naming hyprlock here; hypridle picks it
-- up and runs its lock_cmd. Same path sleep takes, so the locker is defined once
-- (hypridle.conf) instead of being repeated at every call site.
bind(m .. " + L", hl.dsp.exec_cmd("loginctl lock-session"),
    { description = "System: Lock screen" })

-- NOTE: no lid-switch bind. Lid handling belongs to logind, not Hyprland —
--       closing the lid raises PrepareForSleep, which hypridle's before_sleep_cmd
--       already locks on. A bind here would be a second, redundant path, and
--       Switches warns it can conflict with logind's own HandleLidSwitch.

-- ▓▒░ WINDOW MOVE (direction) — SUPER+SHIFT+arrows stays resize, unchanged
bind(m .. " + CTRL + left",  hl.dsp.window.move({ direction = "l" }), { description = "Windows: Move window left" })
bind(m .. " + CTRL + right", hl.dsp.window.move({ direction = "r" }), { description = "Windows: Move window right" })
bind(m .. " + CTRL + up",    hl.dsp.window.move({ direction = "u" }), { description = "Windows: Move window up" })
bind(m .. " + CTRL + down",  hl.dsp.window.move({ direction = "d" }), { description = "Windows: Move window down" })


-- Place the bar directly on the requested screen edge.
bind(m .. " + ALT + up", hl.dsp.global("quickshell:bar-top"), { description = "Panels: Bar at top" })
bind(m .. " + ALT + down", hl.dsp.global("quickshell:bar-bottom"), { description = "Panels: Bar at bottom" })
bind(m .. " + ALT + left", hl.dsp.global("quickshell:bar-left"), { description = "Panels: Bar at left" })
bind(m .. " + ALT + right", hl.dsp.global("quickshell:bar-right"), { description = "Panels: Bar at right" })

-- ▓▒░ MULTI-MONITOR (matters once a laptop is docked)
bind(m .. " + CTRL + ALT + left",  hl.dsp.focus({ monitor = "-1" }), { description = "Workspaces: Focus previous monitor" })
bind(m .. " + CTRL + ALT + right", hl.dsp.focus({ monitor = "+1" }), { description = "Workspaces: Focus next monitor" })
bind(m .. " + ALT + SHIFT + left",  hl.dsp.window.move({ monitor = "-1" }), { description = "Workspaces: Move window to previous monitor" })
bind(m .. " + ALT + SHIFT + right", hl.dsp.window.move({ monitor = "+1" }), { description = "Workspaces: Move window to next monitor" })

-- ▓▒░ WORKSPACE CYCLING (keyboard)
bind(m .. " + bracketleft",  hl.dsp.focus({ workspace = "e-1" }), { description = "Workspaces: Previous workspace" })
bind(m .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }), { description = "Workspaces: Next workspace" })

-- ▓▒░ WINDOW UTILITIES
bind(m .. " + Tab",           hl.dsp.window.cycle_next(),        { description = "Windows: Cycle to next window" })
bind(m .. " + SHIFT + Return", hl.dsp.window.center(),           { description = "Windows: Center floating window" })
bind(m .. " + SHIFT + Space",  hl.dsp.window.pin(),              { description = "Windows: Pin across workspaces" })
bind(m .. " + CTRL + Q",       hl.dsp.window.kill(),             { description = "Windows: Force-kill window (SIGKILL)" })
bind(m .. " + CTRL + G",       hl.dsp.group.toggle(),            { description = "Windows: Toggle tab group" })

-- ▓▒░ COLOR PICKER (SUPER + I) — hyprpicker is installed but was unbound
bind(m .. " + I", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Capture: Pick a colour to the clipboard" })

-- ▓▒░ RELOAD CONFIG
bind(m .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "System: Reload Hyprland config" })

-- BEGIN HYPRLOCK KEYBOARD NAVIGATION
-- These maps are entered only by the active Hyprlock helper and reset on unlock.
-- Only fixed UI commands are written; password text stays entirely in Hyprlock.
local function lock_control(command, target)
    local runtime = os.getenv("XDG_RUNTIME_DIR")
    if not runtime or runtime == "" then
        hl.dispatch(hl.dsp.submap("reset"))
        return
    end
    local queue = io.open(runtime .. "/hyprlock-buttons/commands", "a")
    if not queue then
        hl.dispatch(hl.dsp.submap("reset"))
        return
    end
    queue:write(command .. "\n")
    queue:close()
    if target then hl.dispatch(hl.dsp.submap(target)) end
end

local function define_lock_navigation(name, buttons_focused)
    hl.define_submap(name, function()
        -- Retain all existing lock-safe controls, including Super+K and volume.
        for _, entry in ipairs(lock_safe_binds) do
            hl.bind(entry.keys, entry.action, entry.opts)
        end
        local navigation_keys = {
            { "Tab", "tab-next" }, { "SHIFT + Tab", "tab-prev" },
            { "right", "next" }, { "down", "next" },
            { "left", "prev" }, { "up", "prev" },
        }
        for _, entry in ipairs(navigation_keys) do
            local command = entry[2]
            hl.bind(entry[1], function()
                lock_control(command, "hyprlock-power")
            end, { locked = true, description = "System: Lock screen power navigation" })
        end
        if buttons_focused then
            for _, key in ipairs({ "Return", "KP_Enter", "space" }) do
                hl.bind(key, function()
                    lock_control("activate", "hyprlock-input")
                end, { locked = true, description = "System: Activate selected lock screen power button" })
            end
            hl.bind("Escape", function()
                lock_control("clear", "hyprlock-input")
            end, { locked = true, description = "System: Return to lock screen password" })

            -- Pass ordinary key presses through unchanged while immediately
            -- restoring password focus. Physical codes cover US/Arabic/IME keys
            -- without inspecting or recording the characters being typed.
            -- Keep modifiers and navigation/activation keys in the button map.
            local retained_codes = {
                [9] = true, [23] = true, [36] = true, [65] = true, [104] = true,
                [111] = true, [113] = true, [114] = true, [116] = true,
                [37] = true, [50] = true, [62] = true, [64] = true, [66] = true,
                [77] = true, [78] = true, [92] = true, [105] = true,
                [108] = true, [133] = true, [134] = true,
            }
            for code = 8, 255 do
                if not retained_codes[code] then
                    hl.bind("code:" .. code, function()
                        lock_control("clear", "hyprlock-input")
                    end, { locked = true, ignore_mods = true, non_consuming = true,
                           description = "System: Resume lock screen password entry" })
                end
            end
        end
    end)
end

define_lock_navigation("hyprlock-input", false)
define_lock_navigation("hyprlock-power", true)
-- END HYPRLOCK KEYBOARD NAVIGATION
