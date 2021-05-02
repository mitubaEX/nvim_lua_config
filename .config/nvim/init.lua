vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

require('plugins')
require('keymap')
require('set_config')

-- remove all trailing whitespace on save
vim.cmd('autocmd BufWritePre * %s/\\s\\+$//e')
