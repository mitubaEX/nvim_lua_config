-- for vim-parenmatch
vim.g.loaded_matchparen = true

-- for filetype.nvim
vim.g.did_load_filetypes = 1

require('plugins')
require('keymap')
require('set_config')
require('autocmd_config')
require('lsp_config')
require('utils')

require('plugins.configs.formatter')
require('plugins.configs.lualine')
require('plugins.configs.nvim-tree')
require('plugins.configs.telescope')
