return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				python = { "ruff" },
				go = { "gofmt" },
				rust = { "rustfmt" },
				cpp = { "clang-format" },
				cs = { "dotnet-format" },
				html = { "prettierd" },
				css = { "prettierd" },
				scss = { "prettierd" },
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				json = { "prettierd" },
				jsonc = { "prettierd" },
				php = { "php-cs-fixer" },
				lua = { "stylua" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})
	end,
}
