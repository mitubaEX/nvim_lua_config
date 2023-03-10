-- set leader
vim.keymap.set('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- basic
vim.keymap.set('n', '<Leader>w', ':w<CR>', { noremap = true, silent = false })
vim.keymap.set('i', 'jj', '<ESC>', { noremap = true, silent = true })

-- terminal escape
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', { noremap = true, silent = true })

-- copy 0 register
vim.keymap.set('n', '<Leader>p', '"0p', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>P', '"0P', { noremap = true, silent = true })
vim.keymap.set('v', '<Leader>p', '"0p', { noremap = true, silent = true })

-- noh
vim.keymap.set('n', '<Esc><Esc>', ':noh<CR>', { noremap = true, silent = true })

-- insert new line without entering insert mode
vim.keymap.set('n', '<Leader>o', 'o<Esc>', { noremap = true, silent = false })

-- pbcopy filename
-- only filename
vim.keymap.set('n', '<Leader>c', ':let @"=expand("%:t") | echo expand("%:t") | OscyankRegister<CR>', { noremap = false, silent = false })
-- relative path
vim.keymap.set('n', '<Leader>C', ':let @"=expand("%") | echo expand("%") | OscyankRegister<CR>', { noremap = false, silent = false })
