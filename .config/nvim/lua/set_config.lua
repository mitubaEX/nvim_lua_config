-- basic
vim.api.nvim_command('set confirm')
vim.api.nvim_command('set hidden')

-- clipboard
vim.api.nvim_command('set clipboard+=unnamedplus')

-- inifinite undo
vim.api.nvim_command('set undofile')
vim.api.nvim_command('set undodir=$HOME/.vim/undodir')

-- right vsplit
vim.api.nvim_command('set splitright')

-- search
vim.api.nvim_command('set hlsearch')
vim.api.nvim_command('set ignorecase')
vim.api.nvim_command('set smartcase')
vim.api.nvim_command('set smartindent')
vim.api.nvim_command('set incsearch')
vim.api.nvim_command('set inccommand=split')
vim.api.nvim_command('set nolazyredraw')
vim.api.nvim_command('set magic')

-- tab
vim.api.nvim_command('set tabstop=2')
vim.api.nvim_command('set shiftwidth=2')
vim.api.nvim_command('set expandtab')

-- visual mode
vim.api.nvim_command('set virtualedit=block')

vim.api.nvim_command('set backspace=indent,eol,start')
vim.api.nvim_command('set whichwrap=b,s,<,>,[,],h,l')
