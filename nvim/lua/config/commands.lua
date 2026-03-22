vim.api.nvim_create_user_command("DisableConform", function()
	vim.opt.runtimepath:remove(vim.fn.stdpath("data") .. "/lazy/conform.nvim")

	vim.api.nvim_clear_autocmds({ group = "Conform" })

	pcall(vim.api.nvim_del_user_command, "ConformFormat")
end, {})

vim.api.nvim_create_user_command("EnableConform", function()
	vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/conform.nvim")
	require("conform").setup({
		formatters_by_ft = {
			python = { "black", "ruff" },
			go = { "gofmt" },
			rust = { "rustfmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			cs = { "dotnet-format" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
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
end, {})

function ConformSelectionToUpper()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.fn.getline(start_pos[2], end_pos[2])
	for i, line in ipairs(lines) do
		lines[i] = string.upper(line)
	end
	vim.fn.setline(start_pos[2], lines)
end
