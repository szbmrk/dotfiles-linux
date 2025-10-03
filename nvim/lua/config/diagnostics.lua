vim.diagnostic.config({
    virtual_text = {
        prefix = "● ",
        spacing = 4,
    },
    signs = false,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        header = "",
        prefix = "",
    },
})
