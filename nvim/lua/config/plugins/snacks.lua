return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        picker = {
            layout = { layout = { position = "right" } }
        },
        explorer = {
            enabled = true,
            replace_netrw = true,
            auto_close = true,
        },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        scroll = {
            animate = {
                duration = { step = 15, total = 200 },
                easing = "linear",
            },
            animate_repeat = {
                delay = 100,
                duration = { step = 5, total = 50 },
                easing = "linear",
            },
        },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command
            end,
        })
    end,
}
