return {
	"artemave/workspace-diagnostics.nvim",
	lazy = false,
	config = function()
		require("workspace-diagnostics").setup()
	end,
}
