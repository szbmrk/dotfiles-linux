return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert {
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                }),
            }

            cmp.setup.cmdline({}, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',
            { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },
            'folke/lazydev.nvim',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            require('lazydev').setup()
            require('mason').setup({
                install_root_dir = "C:/nvim-data/mason"
            })
            require('mason-lspconfig').setup({
                automatic_installation = true, -- Auto-install LSPs
            })
            vim.diagnostic.config({
                virtual_text = {
                    source = "always", -- Show the error source
                    prefix = '●', -- Could be '■', '▶', etc
                    spacing = 4,
                },
                signs = false, -- Disable signs in the gutter
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = {
                    focusable = true,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
            function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = opts.border or 'rounded'
                opts.max_width = opts.max_width or math.floor(vim.o.columns * 0.8)
                opts.max_height = opts.max_height or math.floor(vim.o.lines * 0.8)
                return orig_util_open_floating_preview(contents, syntax, opts, ...)
            end

            local on_attach = function(client, bufnr)
                local opts = { buffer = bufnr, remap = false }
                vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
            end

            local servers = {
                'ts_ls',
                'html',
                'cssls',
                'rust_analyzer',
                'pyright',
                'omnisharp',
                'lua_ls',
            }

            -- Special setup for Lua
            lspconfig.lua_ls.setup {
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        diagnostics = { globals = { 'vim' } },
                        workspace = { library = { vim.api.nvim_get_runtime_file('', true), "${3rd}/love2d/library" } },
                        telemetry = { enable = false },
                    }
                }
            }

            -- Setup remaining servers
            for _, lsp in ipairs(servers) do
                if lsp ~= 'lua_ls' then -- Skip Lua as we configured it separately
                    lspconfig[lsp].setup {
                        on_attach = on_attach,
                        capabilities = capabilities,
                    }
                end
            end

            -- Enhanced Omnisharp setup
            lspconfig.omnisharp.setup {
                on_attach = on_attach,
                capabilities = capabilities,
                cmd = { "omnisharp" },
                enable_roslyn_analyzers = true,
                enable_import_completion = true,
                organize_imports_on_format = true,
                enable_decompilation_support = true,
                settings = {
                    FormattingOptions = {
                        EnableEditorConfigSupport = true,
                    }
                }
            }
        end,
    },
}
