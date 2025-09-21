if vim.g.vscode then
    require("config.vscode")
    require("config.vscode_keymaps")
else
    require("config")
end
