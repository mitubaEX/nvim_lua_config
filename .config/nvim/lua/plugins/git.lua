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
		-- Neogit defaults to `kind = "tab"`, which spawns a new Vim tab page.
		-- That collides with bufferline.nvim's `mode = "tabs"` setup (see
		-- ui.lua): a worktree tab and the Neogit tab share the same cwd, so
		-- they render with the same name_formatter label and the tab-aware
		-- `<leader>gws` picker can't tell them apart. Replace the current
		-- buffer instead — `:q` returns to the prior buffer.
		opts = {
			kind = "replace",
		},
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
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("git_worktree").setup({
				cleanup_buffers = true, -- Clean up old buffers when switching
				worktreeinclude_file = ".worktreeinclude", -- Copy paths listed here into new worktrees
			})
		end,
		cmd = {
			"GitWorktreeCreate",
			"GitWorktreeSwitch",
			"GitWorktreeDelete",
			"GitWorktreeList",
			"GitWorktreeCurrent",
			"GitWorktreeReview",
			"GitWorktreeCleanup",
			"GitWorktreeForceCleanup",
		},
		keys = {
			{
				"<leader>gwc",
				function()
					require("plugins.configs.worktree").create()
				end,
				desc = "Worktree: create",
			},
			{
				"<leader>gwC",
				function()
					require("plugins.configs.worktree").create_from_default()
				end,
				desc = "Worktree: create from default branch",
			},
			{
				"<leader>gws",
				function()
					require("plugins.configs.worktree").switch()
				end,
				desc = "Worktree: switch (Telescope)",
			},
			{
				"<leader>gwd",
				function()
					require("plugins.configs.worktree").delete()
				end,
				desc = "Worktree: delete by branch",
			},
			{ "<leader>gwl", "<cmd>GitWorktreeList<CR>", desc = "Worktree: list" },
			{ "<leader>gw.", "<cmd>GitWorktreeCurrent<CR>", desc = "Worktree: show current" },
			{
				"<leader>gwr",
				function()
					require("plugins.configs.worktree").review_pr()
				end,
				desc = "Worktree: review PR",
			},
			{
				"<leader>gwa",
				function()
					require("plugins.configs.worktree").create_with_claude()
				end,
				desc = "Worktree: create + open claude",
			},
			{
				"<leader>gwA",
				function()
					require("plugins.configs.worktree").create_from_default_with_claude()
				end,
				desc = "Worktree: create (from default) + claude",
			},
			{
				"<leader>gwR",
				function()
					require("plugins.configs.worktree").review_pr_with_claude()
				end,
				desc = "Worktree: review PR + claude --from-pr",
			},
			{
				"<leader>gwt",
				function()
					require("plugins.configs.worktree").create_with_task()
				end,
				desc = "Worktree: task -> claude picks branch + opens claude",
			},
			{
				"<leader>gwT",
				function()
					require("plugins.configs.worktree").create_from_default_with_task()
				end,
				desc = "Worktree: task (from default) -> claude picks branch + opens claude",
			},
			{ "<leader>gwX", "<cmd>GitWorktreeCleanup<CR>", desc = "Worktree: cleanup all" },
		},
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
