local opt = vim.opt

-- Cursorline
opt.cursorline = true

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.shiftround = true
opt.smartindent = true

-- Search settings
opt.ignorecase = true
opt.smartcase = true

-- Word wrap
opt.wrap = false

-- System clipboard
opt.clipboard:append(
    vim.env.SSH_TTY
    and ""
    or "unnamedplus"
)

-- Infinite undo
opt.undofile = true

-- Enable line wrapping for markdown files
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
        vim.opt_local.wrap = true
        vim.keymap.set('n', '<Down>', 'gj', { noremap = true })
        vim.keymap.set('n', '<Up>', 'gk', { noremap = true })
        vim.keymap.set('i', '<Down>', '<Esc>gja', { noremap = true })
        vim.keymap.set('i', '<Up>', '<Esc>gka', { noremap = true })
    end
})
