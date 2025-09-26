vim.g.mapleader = " "

local set_keymap = vim.keymap.set

set_keymap("", "<Esc>", "<Esc><cmd>noh<CR>", {
	silent = true,
})

-- Save file with Ctrl+S
set_keymap("n", "<C-s>", ":w<CR>", {
	silent = true,
})
set_keymap("i", "<C-s>", "<Esc>:w<CR>a", {
	silent = true,
})

-- Undo with Ctrl+Z
set_keymap("n", "<C-z>", "u", {
	silent = true,
})
set_keymap("i", "<C-z>", "<C-o>u", {
	silent = true,
})

-- Redo with Ctrl+Y
set_keymap("n", "<C-y>", "<C-r>", {
	silent = true,
})
set_keymap("i", "<C-y>", "<C-o><C-r>", {
	silent = true,
})

-- jj to exit insert mode
set_keymap("i", "jj", "<Esc>", {
	silent = true,
})

-- Paste without yanking
set_keymap("v", "p", '"_dp', {
	silent = true,
})

-- Delete without yanking
set_keymap("n", "dd", '"_dd', {
	silent = true,
})

set_keymap("v", "d", '"_d', {
	silent = true,
})

set_keymap("n", "<leader>d", '"_dd', {
	silent = true,
})

-- Quit Neovim with Ctrl+Q or Leader+Q
set_keymap("n", "<C-q>", ":q<CR>", {
	silent = true,
})
set_keymap("n", "<Leader>q", ":q<CR>", {
	silent = true,
})
set_keymap("i", "<C-q>", "<Esc>:q<CR>", {
	silent = true,
})

-- Indent with Tab and Shift+Tab
set_keymap("v", "<Tab>", ">gv", {
	silent = true,
})
set_keymap("v", "<S-Tab>", "<gv", {
	silent = true,
})
set_keymap("n", "<Tab>", ">>", {
	silent = true,
})
set_keymap("n", "<S-Tab>", "<<", {
	silent = true,
})

-- Duplicate current line
set_keymap("n", "<C-d>", "yyp", {
	silent = true,
})
set_keymap("v", "<C-d>", "y'>p", {
	silent = true,
})
set_keymap("i", "<C-d>", "<Esc>yypa", {
	silent = true,
})

-- Ctrl+A to select all
set_keymap("n", "<C-a>", "ggVG", {
	silent = true,
})
set_keymap("i", "<C-a>", "<Esc>ggVG", {
	silent = true,
})

-- Backspace to delete without yanking
set_keymap("n", "<BS>", "x", {
	silent = true,
})
set_keymap("v", "<BS>", "d", {
	silent = true,
})

-- Ctrl+X to cut
set_keymap("v", "<C-x>", "d", {
	silent = true,
})
set_keymap("n", "<C-x>", "dd", {
	silent = true,
})
set_keymap("i", "<C-x>", "<Esc>dd", {
	silent = true,
})

-- Comment line
-- set_keymap("n", "/", "gcc", {
-- 	silent = true,
-- })
-- set_keymap("v", "/", "gc", {
-- 	silent = true,
-- })

-- Search with Ctrl+FZF
set_keymap({ "n", "v", "i" }, "<C-f>", ":/", {
	silent = true,
})

-- Find files with FZF
set_keymap("n", "<C-p>", ":FzfLua files <CR>", {
	silent = true,
})
set_keymap("n", "<leader>ff", ":FzfLua files <CR>", {
	silent = true,
})

-- Find all with FZF
set_keymap("n", "<leader>fs", ":FzfLua live_grep <CR>", {
	silent = true,
})

-- Find in current file with FZF
set_keymap("n", "<leader>fw", ":FzfLua grep_cword<CR>", {
	silent = true,
})

-- Find buffers with FZF
set_keymap("n", "<leader>fb", ":FzfLua buffers<CR>", {
	silent = true,
})

-- Leader+Tab switch back and forth between current and previous buffer
set_keymap("n", "<leader><Tab>", ":b#<CR>", {
	silent = true,
})

-- Replace all in file
set_keymap("n", "<leader>r", ":%s/", {
	silent = true,
})

-- Move to end/start of line
set_keymap("n", "<S-Left>", "g^", {
	noremap = true,
})
set_keymap("n", "<S-Right>", "g$", {
	noremap = true,
})
set_keymap("i", "<S-Left>", "<Esc>g^i", {
	noremap = true,
})
set_keymap("i", "<S-Right>", "<Esc>g$a", {
	noremap = true,
})

-- LSP keymaps
set_keymap("n", "<leader>vrr", vim.lsp.buf.references)
set_keymap("i", "<F2>", vim.lsp.buf.rename)
set_keymap("n", "<F2>", vim.lsp.buf.rename)
set_keymap("n", "<C-h>", vim.lsp.buf.signature_help)
set_keymap("i", "<C-h>", vim.lsp.buf.signature_help)
set_keymap("n", "K", vim.lsp.buf.hover)
set_keymap("n", "<leader>vd", vim.diagnostic.open_float)
set_keymap("n", "<leader>vca", vim.lsp.buf.code_action)
set_keymap("n", "gd", function()
	local params = vim.lsp.util.make_position_params(0, "utf-8")
	vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, _)
		if err then
			vim.notify("Error getting definition: " .. err.message, vim.log.levels.ERROR)
			return
		end
		if not result or vim.tbl_isempty(result) then
			vim.notify("No definition found", vim.log.levels.WARN)
			return
		end
		if #result == 1 then
			vim.lsp.util.show_document(result[1], "utf-8")
		else
			local items = vim.lsp.util.locations_to_items(result, "utf-8")
			vim.fn.setqflist({}, " ", {
				title = "LSP Definitions",
				items = items,
			})
			vim.cmd("copen")
		end
	end)
end)

-- Conform keymaps
set_keymap("n", "<leader>fd", function()
	require("conform").format({
		async = true,
		lsp_fallback = true,
	})
end)

-- Move line up with Alt+Up
set_keymap("i", "<A-Up>", "<Esc>:move .-2<CR>gi")
set_keymap("n", "<A-Up>", ":move .-2<CR>gv")
set_keymap("v", "<A-Up>", ":move '<-2<CR>gv=gv")

-- Move line down with Alt+Down
set_keymap("i", "<A-Down>", "<Esc>:move .+1<CR>gi")
set_keymap("n", "<A-Down>", ":move .+1<CR>")
set_keymap("v", "<A-Down>", ":move '>+1<CR>gv=gv")

-- Leader+E to open oil
set_keymap("n", "<leader>e", function()
	require("oil").open()
end)

-- Trouble keymaps
set_keymap("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
set_keymap("n", "<leader>xl", "<cmd>Trouble lsp toggle<cr>")
set_keymap("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>")
set_keymap("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>")
