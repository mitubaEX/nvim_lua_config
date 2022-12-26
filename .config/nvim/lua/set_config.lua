-- basic
vim.opt.confirm = true
vim.opt.hidden = true
vim.opt.number = true

-- clipboard
vim.opt.clipboard = vim.opt.clipboard + 'unnamedplus'

-- inifinite undo
vim.api.nvim_command('set undofile')
vim.api.nvim_command('set undodir=$HOME/.vim/undodir')

-- right vsplit
vim.opt.splitright = true

-- search
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.incsearch = true
vim.opt.inccommand = 'split'
vim.opt.magic = true

-- tab
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- visual mode
vim.opt.virtualedit = 'block'

vim.opt.backspace = 'indent,eol,start'
vim.opt.whichwrap = 'b,s,<,>,[,],h,l'

-- disable mouse
vim.opt.mouse = ''

vim.opt.swapfile = false

-- vim.opt.cursorline = true
