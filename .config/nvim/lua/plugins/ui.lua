return {
  -- syntax
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

  -- editor ui
  {
    'nvim-lualine/lualine.nvim',
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    dependencies = { 'kyazdani42/nvim-web-devicons', 'ryanoasis/vim-devicons' },
    config = require('plugins.configs.lualine'),
  },
  {
    'kyazdani42/nvim-tree.lua',
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = require('plugins.configs.nvim-tree'),
  },
  -- {
  --   'lukas-reineke/indent-blankline.nvim',
  --   event = "BufReadPost",
  --   config = function ()
  --     require("indent_blankline").setup {
  --       -- for example, context is off by default, use this to turn it on
  --       show_current_context = true,
  --       show_current_context_start = false,
  --     }
  --   end
  -- },
  -- {
  --   'levouh/tint.nvim',
  --   event = "BufReadPost",
  --   config = function ()
  --     require("tint").setup({})
  --   end
  -- },

  -- startify
  {
    'goolord/alpha-nvim',
    event = "BufWinEnter",
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function ()
      require'alpha'.setup(require'alpha.themes.startify'.opts)
    end
  },
}
