return {
	"kevinhwang91/nvim-hlslens",
	as = "hlslens",
	opts = {},
	config = function()
		require("hlslens").setup({
			enable_incsearch = false,
		})
	end,
}
