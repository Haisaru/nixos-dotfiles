-- Hyprland Lua configuration (native hl.* API, Hyprland 0.55+)
-- Wiki: https://wiki.hypr.land/Configuring/Start/
--
-- MODIFIER GRAMMAR (same convention as your niri config):
--   mainMod                -> focus / act on the focused window
--   mainMod + SHIFT        -> move the window
--   mainMod + CTRL         -> monitors
--   mainMod + CTRL + SHIFT -> send the window to another monitor
--   mainMod + ALT          -> act on the whole workspace
-- Non-directional chords (mainMod + F, mainMod + R, ...) are plain mnemonics.
--
-- WORKSPACE MODEL DIFFERENCE FROM NIRI (same caveat as the .conf version):
-- niri addresses "whichever workspace is currently 2nd on THIS monitor".
-- Hyprland workspaces are a fixed global numbering. mainMod + 1..9 below
-- jumps to global workspace N wherever it lives. The "m+1"/"m-1" relative
-- workspace syntax (workspace on the CURRENT monitor) is the real analog
-- to niri's focus-workspace-down/up, used further down.
--
-- A HANDFUL OF DISPATCHERS DON'T HAVE A CONFIRMED hl.dsp.* NAME YET
-- (monitor focus/move, centerwindow, dpms) since the Lua API is very new
-- and not fully documented at every corner. Those binds below shell out to
-- `hyprctl dispatch <name>` instead, which is guaranteed correct because it
-- calls the same underlying dispatcher table the old .conf format used -
-- only the config-authoring layer changed, not the dispatchers themselves.
-- Swap them for native hl.dsp.* calls once you've confirmed the exact name
-- (check :Dispatchers on the wiki or your editor's hl.* LSP completions).

local mainMod = "SUPER"
local term = "kitty"
local launcher = "fuzzel"
local browser = "librewolf"

----------------------
---- MONITORS      ----
----------------------
-- Run `hyprctl monitors` for exact names/modes. position is "XxY" (a
-- literal lowercase x between the numbers), not a comma.
hl.monitor({
    output = "eDP-1",
    mode = "1920x1200@60",
    position = "0x0",
    scale = 1.25,
})
hl.monitor({
    output = "HDMI-A-1",
    mode = "2560x1440@59.951",
    position = "1536x0",
    scale = 1,
})
-- Catch-all for anything else you plug in
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

----------------------
---- AUTOSTART      ----
----------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("swaybg -i /home/jason/dotfiles/assets/active.jpg -m fill")
    hl.exec_cmd("/home/jason/.config/niri/clipboard-watch.sh")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("xhost +SI:localuser:root 2>/dev/null || true")
end)

----------------------
---- LOOK & FEEL    ----
----------------------
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border = "rgba(9bdcffff)",
            inactive_border = "rgba(30485aaa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 0,              -- strict square aesthetic
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 3,
            color = 0x80000000,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 3,
            vibrancy = 1.15,        -- rough analog of niri's saturation
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        pseudotile = true,
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = false,
    },
})

----------------------
---- INPUT          ----
----------------------
hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        numlock_by_default = true,
        touchpad = {
            natural_scroll = true,
        },
    },
})

----------------------
---- WINDOW RULES   ----
----------------------
-- Picture-in-picture floats + pins
hl.window_rule({
    name = "pip-float",
    match = { class = "^(firefox|librewolf)$", title = "^(Picture-in-Picture)$" },
    float = true,
})
hl.window_rule({
    name = "pip-pin",
    match = { title = "^(Picture-in-Picture)$" },
    pin = true,
})

-- Utility apps float
hl.window_rule({
    name = "utilities-float",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor|satty)$" },
    float = true,
})

-- Portal / share pickers float
hl.window_rule({
    name = "portals-float",
    match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-gnome|hyprland-share-picker)$" },
    float = true,
})

----------------------
---- LAYER RULES    ----
----------------------
-- Blur waybar/launcher/notification layers. Verify these namespaces match
-- reality for your build (e.g. via `hyprctl layers`) - the blur field name
-- on layer_rule is not yet cross-checked against the wiki's Layer-Rules
-- page for this API revision.
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" }, blur = true })
hl.layer_rule({ name = "blur-launcher", match = { namespace = "^launcher$" }, blur = true })
hl.layer_rule({ name = "blur-notifications", match = { namespace = "^notifications$" }, blur = true })

----------------------
---- KEYBINDINGS    ----
----------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(term .. " -e yazi"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(term .. " -e nvim"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("/home/jason/.config/waybar/scripts/theme-switcher.sh menu"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(term .. " -e btop"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("/home/jason/.config/waybar/scripts/wofi-power.sh"))

-- Screen lock - pick a locker (hyprlock recommended) and uncomment.
-- hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("hyprlock"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprctl dispatch centerwindow"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Focus navigation
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Window movement
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Resizing (relative pixel delta, held-down repeat)
hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

-- Split direction toggle (dwindle) - closest analog to niri's width presets
hl.bind(mainMod .. " + R", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Groups (closest analog to niri's consume/expel-into-column)
hl.bind(mainMod .. " + comma", hl.dsp.group.toggle())

-- Workspaces - GLOBAL numbers, not per-monitor like niri
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Next/previous workspace ON THE CURRENT MONITOR - the real analog to
-- niri's focus-workspace-down/up
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + Page_Down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + Page_Up", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + U", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ workspace = "m-1" }))

hl.bind(mainMod .. " + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.window.move({ workspace = "m-1" }))

-- ── Monitors ─────────────────────────────────────────────────────────────
-- Using the hyprctl dispatch fallback here (see note at top of file).
hl.bind(mainMod .. " + CTRL + left", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor l"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor r"))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor l"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor r"))

-- Send the focused window to another monitor
hl.bind(mainMod .. " + CTRL + SHIFT + left", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:l"))
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:r"))
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:l"))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:r"))

-- Send the whole current workspace to another monitor
hl.bind(mainMod .. " + ALT + left", hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor l"))
hl.bind(mainMod .. " + ALT + right", hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor r"))
hl.bind(mainMod .. " + ALT + H", hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor l"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor r"))

hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl dispatch dpms toggle"))

-- Scroll bindings (workspace switching on current monitor)
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "m-1" }))

-- Screenshots - reusing your existing script
hl.bind("Print", hl.dsp.exec_cmd("/home/jason/.config/niri/screenshot.sh region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("/home/jason/.config/niri/screenshot.sh screen"))
-- hl.bind("CTRL + Print", hl.dsp.exec_cmd("grimblast copysave screen"))
-- hl.bind("ALT + Print", hl.dsp.exec_cmd("grimblast copysave active"))

-- Hardware controls (Volume, Brightness, Media)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Quit session - hl.dsp.exit() has no confirmation dialog, same caveat as
-- the .conf version: niri's `quit` asked first, this does not.
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
