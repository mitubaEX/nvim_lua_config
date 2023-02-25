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
    requires = { 'tpope/vim-fugitive' },
    config = function ()
      vim.keymap.set('n', '<C-g>l', ":GV!<CR>", { noremap = true, silent = true })
    end
  },
  {'mitubaEX/blame_open.nvim'},
  {
    'mitubaEX/to_github_target_pull_request_from_commit_hash.nvim',
    config = function()
      require('to_github_target_pull_request_from_commit_hash').setup()
    end
  },
}
