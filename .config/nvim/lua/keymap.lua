-- set leader
vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- basic
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap('i', 'jj', '<ESC>', { noremap = true, silent = true })

-- tab
vim.api.nvim_set_keymap('n', '<tab>', 'gt', { noremap = true, silent = false })

-- move previous buffer
vim.api.nvim_set_keymap('n', '<Leader>n', ':b #<CR>', { noremap = true, silent = false })

-- terminal escape
vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { noremap = true, silent = true })

-- copy 0 register
vim.api.nvim_set_keymap('n', '<Leader>p', '"0p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>P', '"0P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>p', '"0p', { noremap = true, silent = true })

-- noh
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':noh<CR>', { noremap = true, silent = true })

-- insert new line without entering insert mode
vim.api.nvim_set_keymap('n', '<Leader>o', 'o<Esc>', { noremap = true, silent = false })
