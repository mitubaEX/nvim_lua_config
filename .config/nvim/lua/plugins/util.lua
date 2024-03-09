return {
  {
    "akinsho/toggleterm.nvim",
    event = "BufReadPost",
    config = function ()
      require("toggleterm").setup{ open_mapping = [[<c-l>]] }
      vim.keymap.set('n', '<C-w>w', ':ToggleTerm direction=float<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<Leader>s', ':ToggleTerm size=15 direction=horizontal<CR>', { noremap = true, silent = false })
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
    'lukas-reineke/headlines.nvim',
    ft = 'markdown',
    config = function()
      require('headlines').setup()
    end,
  },
  {
    'mitubaEX/toggle_rspec_file.nvim',
    ft = 'ruby',
    config = function()
      vim.keymap.set('n', '<Leader>x', ':ToggleRspecFile<CR>', { noremap = true, silent = true })
    end
  },
  {
    'itchyny/vim-parenmatch',
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
