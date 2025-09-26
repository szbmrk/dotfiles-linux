return {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    opts = {
        "default-title",
        defaults = {
            formatter = "path.dirname_first",
        },
        files = {
            cwd = vim.fn.getcwd(),
            cwd_prompt = true,
        },
        live_grep = {
            grep_cmd = "rg --column --line-number --no-heading --color=always --smart-case",
            prompt = true,
        },
    }
}