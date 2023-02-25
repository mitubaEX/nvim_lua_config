-- for vim-parenmatch
vim.g.loaded_matchparen = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- example using a list of specs with the default options
vim.g.mapleader = " " -- make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup(require('plugins'), {
  defaults = { lazy = false },
  install = { colorscheme = { "nightfox", "habamax" } },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

require('keymap')
require('set_config')
require('autocmd_config')
require('lsp_config')
require('utils')

require('plugins.configs.formatter')
require('plugins.configs.lualine')
require('plugins.configs.nvim-tree')
require('plugins.configs.telescope')
