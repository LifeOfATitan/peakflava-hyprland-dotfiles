-- indentation use space instead of tabs
vim.opt.expandtab = true
-- size for spaces
vim.opt.tabstop = 4
-- amount of space when using tab
vim.opt.softtabstop = 4

-- indentation options
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- set how nvim displays whitespaces and tabs for cleaner code
vim.opt.list = true
vim.opt.listchars = {tab = '>>', trail = '-', nbsp = '~'}

-- live preview of substitution command
vim.opt.inccommand = 'split'

-- scroll off line
vim.opt.scrolloff = 10

vim.opt.number = true

-- show line cursor is on
vim.opt.cursorline = true

vim.opt.relativenumber = true
vim.opt.shiftwidth = 4

-- sync clipboard between nvim and OS
--vim.schedule(funtion()
    vim.opt.clipboard = 'unnamedplus'
--end)

-- add line breaks
vim.opt.breakindent = true

-- save undo history after nvim closes
vim.opt.undofile = true

-- case insensitive search unless useing \C or more capital letters in search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- confirm before unsaved changes
vim.opt.confirm = true

-- hightlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost',{
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
	vim.highlight.on_yank()
    end,
})






