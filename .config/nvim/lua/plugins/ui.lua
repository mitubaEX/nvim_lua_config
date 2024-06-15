return {
  -- syntax
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    dependencies = { "windwp/nvim-ts-autotag", 'RRethy/nvim-treesitter-endwise', 'andymass/vim-matchup' },
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { "ruby", "javascript", "lua", "vim", "vimdoc", "query", "typescript", "tsx", "json", "yaml", "html", "css", "scss", "bash", "python", "go", "rust", "toml", "jsonc", "dockerfile", "lua" },
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        modules = {},
        matchup = {
          enable = true, -- mandatory, false will disable the whole extension
        },
        autotag = {
          enable = true,
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        endwise = {
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
  {
    'b0o/incline.nvim',
    event = "BufReadPost",
    config = function ()
      require("incline").setup({})
    end
  },

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
