-- for vim-parenmatch
vim.g.loaded_matchparen = true

-- for filetype.nvim
vim.g.did_load_filetypes = 1

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

require("lazy").setup({
  "neovim/nvim-lspconfig",
  'j-hui/fidget.nvim',
  'ray-x/lsp_signature.nvim',
  { 'jose-elias-alvarez/null-ls.nvim', dependencies = { 'yuezk/vim-js' } },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-emoji",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "rafamadriz/friendly-snippets",
      'mitubaEX/cmp-account-items',
    }
  },
  {
    'windwp/nvim-autopairs',
    config = function ()
      require('nvim-autopairs').setup{}
    end
  },

  { 'nvim-lualine/lualine.nvim', dependencies = { 'kyazdani42/nvim-web-devicons', 'ryanoasis/vim-devicons' } },

  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    priority = 1000,
    dependencies = { "windwp/nvim-ts-autotag" },
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        autotag = {
          enable = true,
        },
        highlight = {
          enable = true,
        },
      }
    end
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').load()
    end
  },

  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },

  'kyazdani42/nvim-tree.lua',

  'mhartington/formatter.nvim',
  'greymd/oscyank.vim'
}, {
 defaults = { lazy = true },
 install = { colorscheme = { "tokyonight" } },
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
