return {
	"lervag/vimtex",
	lazy = false,
	init = function()
		vim.g.vimtex_compiler_latexmk_engines = {
			["_"] = "-xelatex",
		}
		vim.g.vimtex_view_method = "general"
		vim.g.vimtex_view_general_viewer = "papers"
		vim.g.vimtex_view_general_options = "@pdf"
	end,
}
