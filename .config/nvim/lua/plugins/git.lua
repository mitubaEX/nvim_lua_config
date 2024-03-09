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
      vim.keymap.set('i', 'C-j', [[copilot#Accept("\<CR>")]])
      vim.g.copilot_no_tab_map = true
    end
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      show_help = "yes", -- Show help text for CopilotChatInPlace, default: yes
      debug = false, -- Enable or disable debug mode, the log file will be in ~/.local/state/nvim/CopilotChat.nvim.log
      disable_extra_info = 'no', -- Disable extra information (e.g: system prompt) in the response.
      language = "English" -- Copilot answer language settings when using default prompts. Default language is English.
      -- proxy = "socks5://127.0.0.1:3000", -- Proxies requests via https or socks.
      -- temperature = 0.1,
    },
    build = function()
      vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>ccb", ":CopilotChatBuffer ", desc = "CopilotChat - Chat with current buffer" },
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      {
        "<leader>ccT",
        "<cmd>CopilotChatVsplitToggle<cr>",
        desc = "CopilotChat - Toggle Vsplit", -- Toggle vertical split
      },
      {
        "<leader>ccv",
        ":CopilotChatVisual ",
        mode = "x",
        desc = "CopilotChat - Open in vertical split",
      },
      {
        "<leader>ccx",
        ":CopilotChatInPlace<cr>",
        mode = "x",
        desc = "CopilotChat - Run in-place code",
      },
      {
        "<leader>ccf",
        "<cmd>CopilotChatFixDiagnostic<cr>", -- Get a fix for the diagnostic message under the cursor.
        desc = "CopilotChat - Fix diagnostic",
      },
      {
        "<leader>ccr",
        "<cmd>CopilotChatReset<cr>", -- Reset chat history and clear buffer.
        desc = "CopilotChat - Reset chat history and clear buffer",
      }
    },
  },
  {
    'akinsho/git-conflict.nvim',
    event = "VeryLazy",
    version = "*",
  }
}
