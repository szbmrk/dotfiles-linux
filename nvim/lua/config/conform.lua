local M = {}

local function js_formatter()
	return { "prettier" }
end

function M.setup()
	local conform = require("conform")

	conform.setup({
		formatters_by_ft = {
			python = { "black", "ruff" },
			go = { "gofmt" },
			rust = { "rustfmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			cs = { "dotnet-format" },

			html = js_formatter,
			css = js_formatter,
			scss = js_formatter,
			javascript = js_formatter,
			javascriptreact = js_formatter,
			typescript = js_formatter,
			typescriptreact = js_formatter,
			json = js_formatter,
			jsonc = js_formatter,

			php = { "php-cs-fixer" },
			lua = { "stylua" },
		},

		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},

		formatters = {
			prettier = {
				prepend_args = { "--ignore-path", ".gitignore", "--ignore-path", ".prettierignore" },
			},
		},
	})
end

return M
