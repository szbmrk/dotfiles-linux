return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		local conform = require("conform")

		local function has_oxfmt_config(bufnr)
			local file = vim.api.nvim_buf_get_name(bufnr)
			local dir = vim.fs.dirname(file)

			return vim.fs.find({
				"oxfmt.config.ts",
				"oxfmt.config.js",
				".oxfmtrc.json",
			}, {
				path = dir,
				upward = true,
			})[1] ~= nil
		end

		local function js_formatter(bufnr)
			if has_oxfmt_config(bufnr) then
				return { "oxfmt" }
			end

			return { "prettier" }
		end

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
					prepend_args = { "--tab-width", "4" },
				},
				oxfmt = {
					command = "npx",
					args = {
						"oxfmt",
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
				},
			},
		})
	end,
}
