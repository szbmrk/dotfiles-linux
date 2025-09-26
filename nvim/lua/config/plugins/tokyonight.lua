return {
    "folke/tokyonight.nvim",
    as = "tokyonight",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
        require(
            "tokyonight"
        ).setup({
            transparent = true,
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = false },
                functions = {},
                variables = {},
                sidebars = "transparent",
            },
        })
        vim.cmd.colorscheme(
            "tokyonight"
        )
    end,
}
