hl.monitor({
	output = "eDP-1",
	mode = "1920x1080",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "DP-3",
	mode = "2560x1440@179.95",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
	mirror = "eDP-1",
})
