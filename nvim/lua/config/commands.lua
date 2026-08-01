vim.api.nvim_create_user_command("DisableConform", function()
	vim.opt.runtimepath:remove(vim.fn.stdpath("data") .. "/lazy/conform.nvim")

	vim.api.nvim_clear_autocmds({ group = "Conform" })

	pcall(vim.api.nvim_del_user_command, "ConformFormat")
end, {})

vim.api.nvim_create_user_command("EnableConform", function()
	vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/conform.nvim")
	require("config.conform").setup()
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
