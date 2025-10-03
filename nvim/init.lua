if vim.g.vscode then
    require("config.vscode")
    require("config.vscode_keymaps")
else
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    require("config")
end
