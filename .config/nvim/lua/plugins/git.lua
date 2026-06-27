return {
	{
		"NeogitOrg/neogit",
		-- Loaded on demand: the `:Neogit` command or the <leader>gg keymap. It was
		-- previously `event = "VeryLazy"` (eager at startup) with no keymap, so the
		-- only way to open it was typing `:Neogit`.
		cmd = "Neogit",
		keys = {
			{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Git: Neogit status" },
		},
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
		-- No telescope dependency: the worktree switch/close-tabs pickers run on
		-- Snacks (plugins.configs.worktree) and only call the git_worktree core
		-- API (e.g. delete_worktree), not its telescope extension.
		config = function()
			require("git_worktree").setup({
				cleanup_buffers = true, -- Clean up old buffers when switching
				gh_cmd = "~/bin/gh",
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
				desc = "Worktree: switch (Snacks)",
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
			{
				"<leader>gwq",
				function()
					require("plugins.configs.worktree").close_tabs()
				end,
				desc = "Worktree: close tabs (Snacks, multi-select)",
			},
			{ "<leader>gwX", "<cmd>GitWorktreeCleanup<CR>", desc = "Worktree: cleanup all" },
		},
	},
	{
		-- Ollama (qwen3.5:4b) で日本語の作業内容から英語 kebab-case ブランチ名を
		-- 生成して `git worktree add` まで一発で実行する。AI クラウド課金なし。
		-- 公開コマンド: :Edaha <desc> / :EdahaName <desc> / :EdahaList
		"mitubaEX/edaha.nvim",
		cmd = { "Edaha", "EdahaName", "EdahaList" },
		opts = {},
	},

	-- utils
	{
		"mitubaEX/blame_open.nvim",
		event = "VeryLazy",
	},
}
