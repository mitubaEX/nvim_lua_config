return {
	{
		"greymd/oscyank.vim",
		lazy = false,
	},
	{
		"AndrewRadev/linediff.vim",
		event = "BufReadPost",
	},
	{
		"vim-test/vim-test",
		event = "BufReadPost",
		keys = {
			{ "<Leader>tn", ":TestNearest RAILS_ENV=test<CR>", mode = "n" },
			{ "<Leader>tf", ":TestFile RAILS_ENV=test<CR>", mode = "n" },
		},
		config = function()
			vim.api.nvim_set_var("test#strategy", "neovim")

			vim.api.nvim_set_var("test#ruby#use_binstubs", "1")
		end,
	},
	{
		"nvim-neotest/neotest",
		event = "BufReadPost",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"olimorris/neotest-rspec",
			"nvim-neotest/neotest-go",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-rspec"),
					require("neotest-go"),
				},
			})
		end,
	},
	{
		"rgroli/other.nvim",
		event = "BufReadPost",
		config = function()
			require("other-nvim").setup({
				mappings = {
					"rails",
					"golang",
					"react",
					"rust",
				},
			})
		end,
	},
	{
		"itchyny/vim-parenmatch",
		event = "BufReadPost",
	},
	{
		"mogulla3/copy-file-path.nvim",
		event = "BufReadPost",
	},

	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		event = "BufReadPost",
		-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
		-- event = {
		--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
		--   -- refer to `:h file-pattern` for more examples
		--   "BufReadPre path/to/my-vault/*.md",
		--   "BufNewFile path/to/my-vault/*.md",
		-- },
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",

			-- see below for full list of optional dependencies 👇
		},
		opts = {
			workspaces = {
				{
					name = "personal",
					path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-vault",
				},
			},
			daily_notes = {
				folder = "daily",
				date_format = "%Y-%m-%d",
			},

			-- see below for full list of options 👇
		},
	},
	{
		"mitubaEX/server.nvim",
		event = "BufReadPost",
		config = function()
			require("server").setup({
				servers = {
					{
						name = "ExampleServer",
						command = "python3 -m http.server",
						port = 8000,
					},
				},
			})
		end,
	},
}
