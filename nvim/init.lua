if vim.g.vscode then
	require("config.vscode")
	require("config.vscode_keymaps")
else
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "<filetype>" },
		callback = function()
			vim.treesitter.start()
		end,
	})
	require("config")
end
