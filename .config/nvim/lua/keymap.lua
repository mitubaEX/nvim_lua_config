-- set leader
vim.keymap.set('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- basic
vim.keymap.set('n', '<Leader>w', ':w<CR>', { noremap = true, silent = false })
vim.keymap.set('i', 'jj', '<ESC>', { noremap = true, silent = true })

-- tab
-- vim.keymap.set('n', '<tab>', 'gt', { noremap = true, silent = false })

-- move previous buffer
-- vim.keymap.set('n', '<Leader>n', ':b #<CR>', { noremap = true, silent = false })

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
vim.keymap.set('n', '<Leader>c', ':!echo -n "%:t" | pbcopy<CR>', { noremap = false, silent = false })
-- relative path
vim.keymap.set('n', '<Leader>C', ':!echo -n "%" | pbcopy<CR>', { noremap = false, silent = false })

-- save terminal output to file
vim.keymap.set('n', '<Leader>>', ':w !tee >> terminal_output.txt<CR>', { noremap = false, silent = false })
