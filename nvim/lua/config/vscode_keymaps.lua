vim.g.mapleader = " "
vim.g.maplocalleader = " "

local set_keymap = vim.keymap.set
local opts = {
	noremap = true,
	silent = true,
}

set_keymap({ "n", "v" }, "y", '"+y', opts)
set_keymap({ "n", "v" }, "p", '"+p', opts)
set_keymap({ "n", "v", "i" }, "<C-a>", "<Esc>ggVG", opts)
set_keymap("v", "<S-Tab>", "<gv", opts)
set_keymap("v", "<Tab>", ">gv", opts)
set_keymap("n", "<leader>d", '"_dd', opts)
set_keymap("n", "<C-z>", "u", opts)
set_keymap("n", "<Esc>", "<Esc>:noh<CR>", opts)
set_keymap("n", "<leader>r", ":%s/", opts)
set_keymap("v", "p", '"_dp', opts)
set_keymap("v", "d", '"_d', opts)

set_keymap("v", "<C-x>", '"+d"', opts)
set_keymap("n", "<C-x>", '"+dd"', opts)
set_keymap("i", "<C-x>", '"<Esc>+dd"', opts)

-- call vscode commands from neovim
set_keymap({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
set_keymap(
	{ "n", "v" },
	"<leader>e",
	"<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>"
)
set_keymap({ "n", "v" }, "<C-f>", "<cmd>lua require('vscode').action('actions.find)<CR>")
set_keymap({ "n", "v" }, "<leader>fs", "<cmd>lua require('vscode').action('actions.find')<CR>")
set_keymap({ "n", "v" }, "<C-j>", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
set_keymap({ "n", "v" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
set_keymap({ "n", "v" }, "/", "<cmd>lua require('vscode').action('editor.action.commentLine')<CR>")
set_keymap("v", "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatSelection')<CR>")
