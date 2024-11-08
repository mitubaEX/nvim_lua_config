return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-emoji",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-cmdline",
      -- "hrsh7th/cmp-vsnip",
      -- "hrsh7th/vim-vsnip",
      -- "rafamadriz/friendly-snippets",
      "zbirenbaum/copilot-cmp"
      -- 'mitubaEX/cmp-account-items',
    },
    config = require('plugins.configs.nvim-cmp')
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function ()
      require('nvim-autopairs').setup{}
    end
  },
  -- {
  --   'saghen/blink.cmp',
  --   lazy = false, -- lazy loading handled internally
  --   dependencies = 'rafamadriz/friendly-snippets',
  --
  --   -- use a release tag to download pre-built binaries
  --   version = 'v0.*',
  --
  --   ---@module 'blink.cmp'
  --   ---@type blink.cmp.Config
  --   opts = {
  --     keymap = { preset = 'enter' },
  --
  --     highlight = {
  --       -- sets the fallback highlight groups to nvim-cmp's highlight groups
  --       -- useful for when your theme doesn't support blink.cmp
  --       -- will be removed in a future release, assuming themes add support
  --       use_nvim_cmp_as_default = true,
  --     },
  --     -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
  --     -- adjusts spacing to ensure icons are aligned
  --     nerd_font_variant = 'mono',
  --
  --     -- experimental auto-brackets support
  --     -- accept = { auto_brackets = { enabled = true } }
  --
  --     -- experimental signature help support
  --     -- trigger = { signature_help = { enabled = true } }
  --   }
  -- },
}
