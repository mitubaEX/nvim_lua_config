vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

require('plugins')
require('keymap')
require('set_config')
require('autocmd_config')
