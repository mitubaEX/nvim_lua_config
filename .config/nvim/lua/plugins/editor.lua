return {
  {
    'mhartington/formatter.nvim',
    event = "InsertEnter",
    config = require('plugins.configs.formatter'),
  },
  {
    'nvim-telescope/telescope.nvim',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = require('plugins.configs.telescope'),
  },
  {
    'kylechui/nvim-surround',
    event = "InsertEnter",
    config = function()
      require('nvim-surround').setup()
    end
  },
  {
    'tyru/columnskip.vim',
    event = "VeryLazy",
    config = function()
      vim.keymap.set('n', '<Leader>j', '<Plug>(columnskip:nonblank:next)', { noremap = false, silent = true })
      vim.keymap.set('n', '<Leader>k', '<Plug>(columnskip:nonblank:prev)', { noremap = false, silent = true })
    end
  },
  {
    'matze/vim-move',
    event = "BufReadPost",
    init = function()
      vim.g.move_key_modifier = 'C'
    end,
  },
  {
    'mg979/vim-visual-multi',
    event = "BufReadPost",
  },

  {
    'pechorin/any-jump.vim',
    event = "BufReadPost",
    init = function()
      vim.g.any_jump_disable_default_keybindings = '1'
    end,
    config = function()
      vim.keymap.set('n', '<Leader>a', ':AnyJump<CR>', { noremap = true, silent = false })
    end
  },
  {
    't9md/vim-quickhl',
    event = "BufReadPost",
    config = function()
      vim.keymap.set('n', '<Leader>m', '<Plug>(quickhl-manual-this)', { noremap = false, silent = false })
      vim.keymap.set('n', '<Leader>M', '<Plug>(quickhl-manual-reset)', { noremap = false, silent = false })
    end
  },
  {
    'xiyaowong/nvim-cursorword',
    event = "BufReadPost",
    config = function()
      vim.api.nvim_set_hl(0, "CursorWord", { bold = 1, default = 1 })
    end
  },
  {
    'gbprod/substitute.nvim',
    event = "VeryLazy",
    config = function()
      require("substitute").setup({})

      vim.keymap.set("n", "s", "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
    end
  },
  {
    'bkad/CamelCaseMotion',
    event = "InsertEnter",
    config = function()
      vim.keymap.set('', 'w', '<Plug>CamelCaseMotion_w', { noremap = false, silent = true })
      vim.keymap.set('', 'e', '<Plug>CamelCaseMotion_e', { noremap = false, silent = true })
      vim.keymap.set('o', 'iw', '<Plug>CamelCaseMotion_iw', { noremap = false, silent = true })
      vim.keymap.set('x', 'iw', '<Plug>CamelCaseMotion_iw', { noremap = false, silent = true })
      vim.keymap.set('o', 'ie', '<Plug>CamelCaseMotion_ie', { noremap = false, silent = true })
      vim.keymap.set('x', 'ie', '<Plug>CamelCaseMotion_ie', { noremap = false, silent = true })
    end
  },
  {
    'numToStr/Comment.nvim',
    event = "BufReadPost",
    config = function()
      require('Comment').setup()
    end
  },
  {
    'Asheq/close-buffers.vim',
    event = { "CursorHold", "CursorHoldI" },
    config = function()
      vim.keymap.set('n', '<C-q>', ':Bdelete hidden<CR>', { noremap = true, silent = true })
    end
  },
  {
    'phaazon/hop.nvim',
    event = "BufReadPost",
    config = function()
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran', term_seq_bias = 0.5, create_hl_autocmd = false, winblend = 0 }
      vim.keymap.set('n', '<Leader>e', ':HopWord<CR>', { noremap = true, silent = true })
    end
  },
  -- {
  --   'rhysd/accelerated-jk',
  --   event = "VeryLazy",
  --   config = function()
  --     vim.keymap.set('n', 'j', '<Plug>(accelerated_jk_gj)', { noremap = false, silent = false })
  --     vim.keymap.set('n', 'k', '<Plug>(accelerated_jk_gk)', { noremap = false, silent = false })
  --   end
  -- },
  {
    'nicwest/vim-camelsnek',
    event = "VeryLazy",
  },
  {
    'rhysd/clever-f.vim',
    event = "VeryLazy",
  }
}
