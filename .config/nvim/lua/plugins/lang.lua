return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    dependencies = {
      'ray-x/lsp_signature.nvim',
      'folke/lsp-trouble.nvim',
      { 'jose-elias-alvarez/null-ls.nvim', dependencies = { 'yuezk/vim-js' } },
    }
  },
  {
    'j-hui/fidget.nvim',
    event = { "BufReadPost", "BufAdd", "BufNewFile" }
  },

  {
    'neoclide/vim-jsx-improve',
    lazy = false,
  },
}
