return {
    'nvim-lualine/lualine.nvim',
    as = 'lualine',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require(
            "lualine"
        ).setup({
            theme = "rose-pine",
        })
    end
}

