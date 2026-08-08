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
