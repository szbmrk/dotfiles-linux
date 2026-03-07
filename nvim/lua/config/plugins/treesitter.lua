return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		local parsers = {
			"bash",
			"c",
			"c_sharp",
			"diff",
			"html",
			"javascript",
			"jsdoc",
			"json",
			-- "jsonc",
			"lua",
			"luadoc",
			"luap",
			"markdown",
			"markdown_inline",
			"printf",
			"python",
			"query",
			"rust",
			"regex",
			"toml",
			"jsx",
			"tsx",
			"typescript",
			"prisma",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
			"hyprlang",
			"rasi",
			"go",
			"gdscript",
			"godot_resource",
			"gdshader",
			"kotlin",
		}

		for _, parser in ipairs(parsers) do
			ts.install(parser)
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = parsers,
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
