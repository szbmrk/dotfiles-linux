hl.window_rule({
	name = "ignore-maximize-requests",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

hl.window_rule({
	name = "opacity",
	match = {
		class = "^(code|com\\.t3tools\\.T3Code)$",
	},
	opacity = 0.95,
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

hl.window_rule({
	name = "dddownload",
	match = {
		title = "^(DDDownload)$",
	},
	float = true,
	center = true,
	size = {
		1100,
		680,
	},
})
