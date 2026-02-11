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
		"mitubaEX/git_worktree.nvim",
		config = function()
			require("git_worktree").setup()
		end,
		opts = {
			cleanup_buffers = true, -- Clean up old buffers when switching
		},
		cmd = {
			"GitWorktreeCreate",
			"GitWorktreeSwitch",
			"GitWorktreeDelete",
			"GitWorktreeList",
			"GitWorktreeCurrent",
		},
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
				copilot_node_command = vim.fn.expand("$HOME") .. "/.asdf/installs/nodejs/24.7.0/bin/node",
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
