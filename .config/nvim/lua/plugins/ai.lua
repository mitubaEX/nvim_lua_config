return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			delay = 200,
			spec = {
				{ "<leader>a", group = "ai/agent" },
				{ "<leader>b", group = "buffer" },
				{ "<leader>c", group = "code" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>q", group = "quit/session" },
				{ "<leader>t", group = "test/terminal" },
				{ "<leader>x", group = "diagnostics" },
			},
		},
	},
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Window left" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Window down" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Window up" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Window right" },
		},
	},
}
