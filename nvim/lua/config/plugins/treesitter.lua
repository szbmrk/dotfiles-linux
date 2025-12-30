return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")

		local parsers_loaded = {}
		local parsers_pending = {}
		local parsers_failed = {}

		local ns = vim.api.nvim_create_namespace("treesitter.async")

		local function start(buf, lang)
			local ok = pcall(vim.treesitter.start, buf, lang)
			if ok then
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
			return ok
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyDone",
			once = true,
			callback = function()
				ts.install({
					"bash",
					"c",
					"c_sharp",
					"diff",
					"html",
					"javascript",
					"jsdoc",
					"json",
					"jsonc",
					"lua",
					"luadoc",
					"luap",
					"markdown",
					"markdown_inline",
					"printf",
					"python",
					"query",
					"regex",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
					"go",
					"gdscript",
					"godot_resource",
					"gdshader",
					max_jobs = 8,
				})
			end,
		})

		vim.api.nvim_set_decoration_provider(ns, {
			on_start = vim.schedule_wrap(function()
				if #parsers_pending == 0 then
					return false
				end
				for _, data in ipairs(parsers_pending) do
					if vim.api.nvim_buf_is_valid(data.buf) then
						if start(data.buf, data.lang) then
							parsers_loaded[data.lang] = true
						else
							parsers_failed[data.lang] = true
						end
					end
				end
				parsers_pending = {}
			end),
		})

		local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

		local ignore_filetypes = {
			"checkhealth",
			"lazy",
			"mason",
			"snacks_dashboard",
			"snacks_notif",
			"snacks_win",
		}

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(event)
				if vim.tbl_contains(ignore_filetypes, event.match) then
					return
				end

				local lang = vim.treesitter.language.get_lang(event.match) or event.match
				local buf = event.buf

				if parsers_failed[lang] then
					return
				end

				if parsers_loaded[lang] then
					start(buf, lang)
				else
					table.insert(parsers_pending, { buf = buf, lang = lang })
				end

				ts.install({ lang })
			end,
		})
	end,
}
