return {
  {
    'lewis6991/gitsigns.nvim',
    event = { "CursorHold", "CursorHoldI" },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
      }
    end
  },
  {
    'junegunn/gv.vim',
    event = { "CursorHold", "CursorHoldI" },
    dependencies = { 'tpope/vim-fugitive' },
    config = function ()
      vim.keymap.set('n', '<C-g>l', ":GV!<CR>", { noremap = true, silent = true })
    end
  },
  {
    'mitubaEX/blame_open.nvim',
    event = "VeryLazy",
  },
  {
    'mitubaEX/to_github_target_pull_request_from_commit_hash.nvim',
    event = "VeryLazy",
    config = function()
      require('to_github_target_pull_request_from_commit_hash').setup()
    end
  },
  {
    'github/copilot.vim',
    event = "InsertEnter",
    config = function ()
      vim.keymap.set('i', 'C-J', [['copilot#Accept("\<CR>")']])
      vim.g.copilot_no_tab_map = true
    end
  }
}
