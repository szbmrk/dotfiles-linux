vim.g.mapleader = " "

local set_keymap = vim.keymap.set

set_keymap("", "<Esc>", "<Esc><cmd>noh<CR>", {
	silent = true,
})

-- Save file with Ctrl+S
set_keymap("n", "<C-s>", ":w<CR>", { silent = true })
set_keymap("i", "<C-s>", "<Esc>:w<CR>a", { silent = true })

-- Undo with Ctrl+Z
set_keymap("n", "<C-z>", "u", { silent = true })
set_keymap("i", "<C-z>", "<C-o>u", { silent = true })

-- Redo with Ctrl+Y
set_keymap("n", "<C-y>", "<C-r>", { silent = true })
set_keymap("i", "<C-y>", "<C-o><C-r>", { silent = true })

-- Paste without yanking
set_keymap("v", "p", '"_dp', { silent = true })

-- Delete without yanking
set_keymap("n", "dd", '"_dd', { silent = true })
set_keymap("v", "d", '"_d', { silent = true })
set_keymap("n", "<leader>d", '"_dd', { silent = true })

-- Quit Neovim with Ctrl+Q or Leader+Q
set_keymap("n", "<C-q>", ":q<CR>", { silent = true })
set_keymap("n", "<Leader>q", ":q<CR>", { silent = true })
set_keymap("i", "<C-q>", "<Esc>:q<CR>", { silent = true })

-- Indent with Tab and Shift+Tab
set_keymap("v", "<Tab>", ">gv", { silent = true })
set_keymap("v", "<S-Tab>", "<gv", { silent = true })
set_keymap("n", "<Tab>", ">>", { silent = true })
set_keymap("n", "<S-Tab>", "<<", { silent = true })

-- Duplicate current line
set_keymap("n", "<C-d>", "yyp", { silent = true })
set_keymap("v", "<C-d>", "y'>p", { silent = true })
set_keymap("i", "<C-d>", "<Esc>yypa", { silent = true })

-- Ctrl+A to select all
-- set_keymap("n", "<C-a>", "ggVG", { silent = true })
-- set_keymap("i", "<C-a>", "<Esc>ggVG", { silent = true })

-- Backspace to delete without yanking
set_keymap("n", "<BS>", "x", { silent = true })
set_keymap("v", "<BS>", "d", { silent = true })

-- Ctrl+X to cut
set_keymap("v", "<C-x>", "d", { silent = true })
set_keymap("n", "<C-x>", "dd", { silent = true })
set_keymap("i", "<C-x>", "<Esc>dd", { silent = true })

-- Search with Ctrl+F
set_keymap({ "n", "v", "i" }, "<C-f>", ":/", { silent = true })

-- Find files with FZF
set_keymap("n", "<C-p>", ":FzfLua files <CR>", { silent = true })
set_keymap("n", "<leader>ff", ":FzfLua files <CR>", { silent = true })
set_keymap("n", "<leader>fs", ":FzfLua live_grep <CR>", { silent = true })
set_keymap("n", "<leader>fw", ":FzfLua grep_cword<CR>", { silent = true })
set_keymap("n", "<leader>fb", ":FzfLua buffers<CR>", { silent = true })

-- Leader+Tab switch back and forth between current and previous buffer
set_keymap("n", "<leader><Tab>", ":b#<CR>", { silent = true })

-- Replace all in file
set_keymap("n", "<leader>r", ":%s/", { silent = true })

-- Move to end/start of line
set_keymap("n", "<S-Left>", "g^", { noremap = true })
set_keymap("n", "<S-Right>", "g$", { noremap = true })
set_keymap("i", "<S-Left>", "<Esc>g^i", { noremap = true })
set_keymap("i", "<S-Right>", "<Esc>g$a", { noremap = true })

-- LSP keymaps
set_keymap("n", "<leader>vrr", vim.lsp.buf.references)
set_keymap("i", "<F2>", vim.lsp.buf.rename)
set_keymap("n", "<F2>", vim.lsp.buf.rename)
set_keymap("n", "<leader>lr", vim.lsp.buf.rename)
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
		vim.lsp.util.show_document(result[1], "utf-8")
	end)
end)

-- Conform keymaps
set_keymap({ "n", "v" }, "<leader>fd", function()
	local conform = require("conform")

	if vim.fn.mode() == "v" then
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")

		local range = {
			start = { start_pos[2], start_pos[3] - 1 },
			["end"] = { end_pos[2], end_pos[3] - 1 },
		}

		conform.format({
			range = range,
			async = true,
			lsp_fallback = true,
		})
	else
		conform.format({
			async = true,
			lsp_fallback = true,
		})
	end
end, { desc = "Format selection or buffer with conform.nvim" })

-- Move line up with Alt+Up
set_keymap("v", "<A-Up>", ":move '<-2<CR>gv=gv")

-- Move line down with Alt+Down
set_keymap("v", "<A-Down>", ":move '>+1<CR>gv=gv")

-- Leader+E to open explorer
set_keymap("n", "<leader>e", ":Neotree toggle reveal<CR>")

-- Trouble keymaps
set_keymap("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
set_keymap("n", "<leader>xl", "<cmd>Trouble lsp toggle<cr>")
set_keymap("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>")
set_keymap("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>")

set_keymap("x", "<leader>a", function()
	vim.cmd('normal! "zy')
	local base = os.getenv("XDG_RUNTIME_DIR")
	if not base or base == "" then
		base = vim.fn.fnamemodify(vim.fn.tempname(), ":h")
	end
	local dir = base .. "/herdr-annotate-" .. vim.loop.getuid()
	vim.fn.mkdir(dir, "p", "0700")
	vim.fn.writefile(vim.split(vim.fn.getreg("z"), "\n"), dir .. "/selection")
	vim.fn.jobstart({ "herdr", "plugin", "action", "invoke", "annotate.capture" })
end, { desc = "Annotate in Herdr" })
