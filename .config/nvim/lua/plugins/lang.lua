return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    dependencies = {
      'ray-x/lsp_signature.nvim',
      'folke/lsp-trouble.nvim',
      { 'jose-elias-alvarez/null-ls.nvim', dependencies = { 'yuezk/vim-js' } },
      'j-hui/fidget.nvim',
    },
    config = require('plugins.configs.lspconfig'),
  },
  {
    'neoclide/vim-jsx-improve',
    lazy = false,
  },
  {
    'tpope/vim-rails',
    ft = 'ruby',
    dependencies = {'tpope/vim-bundler', 'tpope/vim-dispatch'},
  },
  {
    'williamboman/mason.nvim',
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = function ()
      require("mason").setup()
    end
  }
}
