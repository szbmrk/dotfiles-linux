return {
	"nvim-lualine/lualine.nvim",
	as = "lualine",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		theme = "catppuccin",
		sections = {
			lualine_b = {
				"branch",
				"diff",
				{ "diagnostics", sources = { "nvim_workspace_diagnostic" } },
			},
		},
	},
}
