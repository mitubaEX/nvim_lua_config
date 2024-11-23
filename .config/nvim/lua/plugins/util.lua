return {
  {
    "akinsho/toggleterm.nvim",
    lazy = false,
    config = function ()
      require("toggleterm").setup()
    end
  },
  {
    'greymd/oscyank.vim',
    lazy = false,
  },
  {
    'AndrewRadev/linediff.vim',
    event = "BufReadPost",
  },
  {
    'vim-test/vim-test',
    event = "BufReadPost",
    config = function()
      vim.api.nvim_set_var('test#strategy', 'neovim')

      vim.api.nvim_set_var('test#ruby#use_binstubs', '1')

      vim.keymap.set('n', '<Leader>q', ':TestFile<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<Leader>Q', ':TestNearest<CR>', { noremap = true, silent = true })
    end
  },
  {
    "nvim-neotest/neotest",
    event = "BufReadPost",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",
      "nvim-neotest/neotest-go",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rspec"),
          require("neotest-go"),
        },
      })
      -- vim.keymap.set('n', '<Leader>q', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { noremap = true, silent = true })
      -- vim.keymap.set('n', '<Leader>Q', ':lua require("neotest").run.run()<CR>', { noremap = true, silent = true })
      -- vim.keymap.set('n', '<Leader>qo', ':lua require("neotest").output.open({ enter = true })<CR>', { noremap = true, silent = true })
      -- vim.keymap.set('n', '<Leader>qb', ':lua require("neotest").run.run({strategy = "dap"})<CR>', { noremap = true, silent = true })
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    event = "BufReadPost",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    config = function()
      require("dapui").setup()
      require('dap-go').setup()

      -- デバッグ実行はこれ
      -- local dap = require('dap')
      -- dap.listerners.after.event_initialized['dapui_config'] = dapui.open
      -- dap.listerners.after.event_terminated['dapui_config'] = dapui.close

      -- 単体テストはこれ
      -- lua require('dap-go').debug_test()
    end
  },
  {
    'lukas-reineke/headlines.nvim',
    ft = 'markdown',
    config = function()
      require('headlines').setup()
    end,
  },
  {
    'rgroli/other.nvim',
    event = "BufReadPost",
    config = function()
      require('other-nvim').setup({
        mappings = {
          "rails",
          "golang",
          "react",
          "rust",
        },
      })
    end
  },
  {
    'itchyny/vim-parenmatch',
    event = "BufReadPost",
  },
  {
    'mogulla3/copy-file-path.nvim',
    event = "BufReadPost",
  },
  {
    'bloznelis/before.nvim',
    config = function()
      local before = require('before')
      before.setup()
    end
  }
}
