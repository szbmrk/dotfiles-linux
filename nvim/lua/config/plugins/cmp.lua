return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
			})

			cmp.setup.cmdline({}, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
			function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or "rounded"
				opts.max_width = opts.max_width or math.floor(vim.o.columns * 0.8)
				opts.max_height = opts.max_height or math.floor(vim.o.lines * 0.8)
				return orig_util_open_floating_preview(contents, syntax, opts, ...)
			end

			local on_attach = function(client, bufnr)
				local opts = { buffer = bufnr, remap = false }
				vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
			end
		end,
	},
    {
        "williamboman/mason.nvim",
        config = function()
        require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
        require("mason-lspconfig").setup({
            ensure_installed = {
            "pyright",       -- Python linter
            "gopls",          -- Go
            "rust_analyzer",  -- Rust
            "clangd",         -- C++
            "omnisharp",      -- C#
            "html",           -- HTML
            "cssls",          -- CSS
            "jsonls",         -- JSON/JSONC
            "ts_ls",       -- JS/TS
            "phpactor",       -- PHP
            },
        })
        end,
    },
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	dependencies = {
	-- 		"williamboman/mason.nvim",
	-- 		"williamboman/mason-lspconfig.nvim",
	-- 		"folke/lazydev.nvim",
	-- 	},
	-- 	config = function()
	-- 		require("lazydev").setup()
	-- 		require("mason").setup()
	-- 		require("mason-lspconfig").setup({
	-- 			ensure_installed = {
	-- 				"ruff", -- Python
	-- 				"gopls", -- Go
	-- 				"rust_analyzer", -- Rust
	-- 				"clangd", -- C++
	-- 				"omnisharp", -- C#
	-- 				"html", -- HTML
	-- 				"cssls", -- CSS
	-- 				"jsonls", -- JSON/JSONC
	-- 				"ts_ls", -- JS/TS
	-- 				"phpactor", -- PHP
	-- 			},
	-- 		})
	-- 		vim.diagnostic.config({
	-- 			virtual_text = {
	-- 				prefix = "●",
	-- 				spacing = 4,
	-- 			},
	-- 			signs = false,
	-- 			underline = true,
	-- 			update_in_insert = false,
	-- 			severity_sort = true,
	-- 			float = {
	-- 				focusable = true,
	-- 				style = "minimal",
	-- 				border = "rounded",
	-- 				header = "",
	-- 				prefix = "",
	-- 			},
	-- 		})
	--
	-- 		local lspconfig = require("lspconfig")
	--
	-- 		local servers = {
	-- 			"pyright",
	-- 			"gopls",
	-- 			"rust_analyzer",
	-- 			"clangd",
	-- 			"omnisharp",
	-- 			"html",
	-- 			"cssls",
	-- 			"jsonls",
	-- 			"ts_ls",
	-- 			"phpactor",
	-- 		}
	--
	-- 		lspconfig.lua_ls.setup({
	-- 			on_attach = on_attach,
	-- 			capabilities = capabilities,
	-- 			settings = {
	-- 				Lua = {
	-- 					runtime = { version = "LuaJIT" },
	-- 					diagnostics = { globals = { "vim" } },
	-- 					workspace = { library = { vim.api.nvim_get_runtime_file("", true), "${3rd}/love2d/library" } },
	-- 					telemetry = { enable = false },
	-- 				},
	-- 			},
	-- 		})
	--
	-- 		lspconfig.omnisharp.setup({
	-- 			on_attach = on_attach,
	-- 			capabilities = capabilities,
	-- 			cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
	-- 			enable_roslyn_analyzers = true,
	-- 			enable_import_completion = true,
	-- 			enable_ms_build_load_projects_on_demand = false,
	-- 			enable_editorconfig_support = true,
	-- 			enable_suggest_based_on_filename = true,
	-- 			organize_imports_on_format = true,
	-- 			sdk_include_prereleases = true,
	-- 			analyze_open_documents_only = false,
	-- 		})
	--
	-- 		for _, lsp in ipairs(servers) do
	-- 			if lsp ~= "lua_ls" and lsp ~= "omnisharp" then
	-- 				lspconfig[lsp].setup({
	-- 					on_attach = on_attach,
	-- 					capabilities = capabilities,
	-- 				})
	-- 			end
	-- 		end
	-- 	end,
	-- },
}
