local lsp_configs = {
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", ".git" },
  },
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go" },
    root_markers = { "go.mod", ".git" },
  },
  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", ".git" },
  },
  clangd = {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_markers = { "compile_commands.json", ".git" },
  },
  omnisharp = {
    cmd = { "omnisharp" },
    filetypes = { "cs" },
    root_markers = { ".sln", ".git" },
  },
  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    root_markers = { ".git" },
  },
  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_markers = { ".git" },
  },
  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json" },
    root_markers = { ".git" },
  },
  ts_ls = {
    cmd = { "vscode-typescript-language-server", "--stdio" },
    filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    root_markers = { "package.json", ".git" },
  },
  phpactor = {
    cmd = { "phpactor", "language-server" },
    filetypes = { "php" },
    root_markers = { "composer.json", ".git" },
  },
}

for server, config in pairs(lsp_configs) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

vim.o.completeopt = "menu,menuone,noselect"
