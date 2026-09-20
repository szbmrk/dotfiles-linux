return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	priority = 1000,
	config = function()
		require("tiny-inline-diagnostic").setup({
			preset = "classic",
			options = {
				multilines = {
					enabled = true,
					always_show = true,
				},
			},
		})
		vim.diagnostic.config({ virtual_text = false })
	end,
}
