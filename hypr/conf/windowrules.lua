hl.window_rule({
	name = "ignore-maximize-requests",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

hl.window_rule({
	name = "opacity95",
	match = {
		class = "^(code)$",
	},
	opacity = 0.95,
})

hl.window_rule({
	name = "opacity90",
	match = {
		class = "^(org.gnome.Nautilus)$",
	},
	opacity = 0.90,
})

hl.window_rule({
	name = "floating",
	match = {
		class = "^(org.gnome.Nautilus|org.gnome.SystemMonitor)$",
	},
	float = true,
	size = {
		1600,
		900,
	},
})
