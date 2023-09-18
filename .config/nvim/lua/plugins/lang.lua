return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    dependencies = {
      'ray-x/lsp_signature.nvim',
      'folke/lsp-trouble.nvim',
      { 'j-hui/fidget.nvim', tag = 'legacy' },
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
    lazy = false,
    config = function ()
      require("mason").setup()
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {'williamboman/mason.nvim'},
    lazy = false,
    config = function ()
      require("mason-lspconfig").setup()
    end
  }
  -- {
  --   'scalameta/nvim-metals',
  --   ft = 'scala',
  --   requires = { "nvim-lua/plenary.nvim" },
  --   config = function ()
  --     vim.cmd([[augroup lsp]])
  --     vim.cmd([[autocmd!]])
  --     vim.cmd([[autocmd FileType scala setlocal omnifunc=v:lua.vim.lsp.omnifunc]])
  --     -- Java のLSPも利用する場合はここがコンフリクトする可能性がある
  --     vim.cmd([[autocmd FileType java,scala,sbt lua require("metals").initialize_or_attach(metals_config)]])
  --     vim.cmd([[augroup end]])
  --
  --     local metals_config = require("metals").bare_config()
  --
  --     -- Example of settings
  --     metals_config.settings = {
  --       showImplicitArguments = true,
  --       excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
  --     }
  --   end
  -- }
}
