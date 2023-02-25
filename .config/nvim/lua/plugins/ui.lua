return {
  { 'nvim-lualine/lualine.nvim', dependencies = { 'kyazdani42/nvim-web-devicons', 'ryanoasis/vim-devicons' } },
  'kyazdani42/nvim-tree.lua',

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
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme nightfox")
    end
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    config = function ()
      require("indent_blankline").setup {
        -- for example, context is off by default, use this to turn it on
        show_current_context = true,
        show_current_context_start = false,
      }
    end
  },


  {
    'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function ()
      require'alpha'.setup(require'alpha.themes.startify'.opts)
    end
  },

  {
    'levouh/tint.nvim',
    config = function ()
      require("tint").setup({})
    end
  },
}
