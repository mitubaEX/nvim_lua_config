return {
	{
		"NeogitOrg/neogit",
		event = "VeryLazy",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed, not both.
			"ibhagwan/fzf-lua", -- optional
		},
		opts = {},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "CursorHold", "CursorHoldI" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			current_line_blame = true,
		},
	},
  {
    "ThePrimeagen/git-worktree.nvim",
    event = "BufReadPost",
    opts = {},
    config = function(_, opts)
      require("git-worktree").setup(opts)
      require("telescope").load_extension("git_worktree")
      vim.keymap.set("n", "<leader>gw", function()
        require('telescope').extensions.git_worktree.create_git_worktree()
      end, { desc = "Git Worktree" })
      vim.keymap.set("n", "<leader>gW", function()
        require('telescope').extensions.git_worktree.git_worktrees()
      end, { desc = "Git Worktrees" })
    end,
  },

	-- copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					auto_trigger = true,
					keymap = {
						accept = "<Tab>",
					},
				},
				filetypes = {
					markdown = true,
					help = true,
					ruby = true,
					gitcommit = true,
				},
			})
		end,
	},

	-- utils
	{
		"mitubaEX/blame_open.nvim",
		event = "VeryLazy",
	},
	{
		"mitubaEX/to_github_target_pull_request_from_commit_hash.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"akinsho/git-conflict.nvim",
		event = "VeryLazy",
		version = "*",
		opts = {},
	},
}
