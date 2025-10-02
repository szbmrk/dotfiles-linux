return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				python = { "ruff" },
				go = { "gofmt" },
				rust = { "rustfmt" },
                c = {"clang-format"},
				cpp = { "clang-format" },
				cs = { "dotnet-format" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				php = { "php-cs-fixer" },
				lua = { "stylua" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			formatters = {
				prettier = {
					prepend_args = { "--tab-width", "4" },
				},
			},
		})
	end,
}
