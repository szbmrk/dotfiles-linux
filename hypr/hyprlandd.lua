hl.config({
	input = {
		kb_layout = "hu",
		numlock_by_default = true,
		follow_mouse = 1,
		sensitivity = 0,
		accel_profile = "adaptive",

		touchpad = {
			natural_scroll = false,
			scroll_factor = 0.8,
		},
	},
	debug = {
		enable_stdout_logs = true,
	},
})

hl.monitor({
	output = "DP-3",
	mode = "2560x1440@179.95",
	position = "0x0",
	scale = 0.5,
})

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 5,
		border_size = 2,
		col = {
			active_border = "rgba(89b4faff)",
			inactive_border = "rgba(3d3d3dff)",
		},
		layout = "dwindle",
		resize_on_border = true,
	},
	dwindle = {
		force_split = 0,
	},
	decoration = {
		rounding = 5,
		rounding_power = 5,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 2,
			passes = 2,
			vibrancy = 0.1696,
		},
	},
	binds = {
		drag_threshold = 10,
	},
	misc = {
		force_default_wallpaper = 1,
		disable_hyprland_logo = true,
		font_family = "JetBrainsMono Nerd Font Propo",
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 1 }, { 0, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.1, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", speed = 10, bezier = "default", enabled = true })
hl.animation({ leaf = "border", speed = 1, bezier = "linear", enabled = true })
hl.animation({ leaf = "windows", speed = 4.79, bezier = "easeOutQuint", enabled = true })
hl.animation({ leaf = "windowsIn", speed = 4.1, bezier = "easeOutQuint", style = "popin 87%", enabled = true })
hl.animation({ leaf = "windowsOut", speed = 1.49, bezier = "linear", style = "popin 87%", enabled = true })
hl.animation({ leaf = "fadeIn", speed = 1.73, bezier = "almostLinear", enabled = true })
hl.animation({ leaf = "fadeOut", speed = 1.46, bezier = "almostLinear", enabled = true })
hl.animation({ leaf = "fade", speed = 3.03, bezier = "quick", enabled = true })
hl.animation({ leaf = "layers", speed = 3.81, bezier = "easeOutQuint", enabled = true })
hl.animation({ leaf = "layersIn", speed = 4, bezier = "easeOutQuint", style = "fade", enabled = true })
hl.animation({ leaf = "layersOut", speed = 1.5, bezier = "linear", style = "fade", enabled = true })
hl.animation({ leaf = "fadeLayersIn", speed = 1.79, bezier = "almostLinear", enabled = true })
hl.animation({ leaf = "fadeLayersOut", speed = 1.39, bezier = "almostLinear", enabled = true })
hl.animation({ leaf = "workspaces", enabled = false })

local mod = "SUPER"

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:272", hl.dsp.window.float(), { click = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + D", hl.dsp.exec_cmd("wezterm"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("pkill rofi || ~/.config/scripts/rofi-run.sh"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + T", function()
	if hl.get_active_window().floating then
		hl.dispatch(hl.dsp.window.float())
	else
		hl.dispatch(hl.dsp.window.float())
		hl.dispatch(hl.dsp.window.resize({ x = 1600, y = 900 }))
		hl.dispatch(hl.dsp.window.center())
	end
end)

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + UP", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }))

hl.bind(mod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mod .. " + A", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mod .. " + D", hl.dsp.focus({ workspace = "r+1" }))

hl.bind(mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))

hl.bind("mouse:276", hl.dsp.pass({ window = "class:^(discord)$" }))
hl.bind("mouse:276", hl.dsp.pass({ window = "class:^(org.wezfurlong.wezterm)$" }))
