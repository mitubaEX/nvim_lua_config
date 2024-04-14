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
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "rafamadriz/friendly-snippets",
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
}
