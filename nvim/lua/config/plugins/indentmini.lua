return {
    "nvimdev/indentmini.nvim",
    as = "indentmini",
    config = function()
        require(
            "indentmini"
        ).setup({
            char = '│',
            minlevel = 1,
            only_current = false
        })
    end,
}
