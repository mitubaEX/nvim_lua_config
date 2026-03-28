vim.opt.confirm = true
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.winminwidth = 5
vim.opt.pumheight = 12

-- clipboard (OSC 52)
vim.opt.clipboard = "unnamedplus"

-- inifinite undo
vim.api.nvim_command("set undofile")
vim.api.nvim_command("set undodir=$HOME/.vim/undodir")

-- right vsplit
vim.opt.splitright = true

-- search
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.infercase = true
vim.opt.incsearch = true
vim.opt.inccommand = "split"
vim.opt.magic = true

-- tab
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- visual mode
vim.opt.virtualedit = "block"

vim.opt.backspace = "indent,eol,start"
vim.opt.whichwrap = "b,s,<,>,[,],h,l"

-- disable mouse
vim.opt.mouse = ""

vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.laststatus = 3
