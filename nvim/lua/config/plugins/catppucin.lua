return {
	"catppuccin/nvim",
	as = "catppuccin",
	config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = true,
            show_end_of_buffer = false,
            term_colors = true,
            no_italic = true,
            integrations = {
                mason = true,
                cmp = true,
                fzf = true,
                lualine = true,
                harpoon = true,
                native_lsp = {
                    enabled = true,
                },
            },
        })
	end,
}

