return {
	{
		"AndrewRadev/linediff.vim",
		event = "BufReadPost",
	},
	{
		"vim-test/vim-test",
		event = "BufReadPost",
		keys = {
			{ "<Leader>tn", ":TestNearest RAILS_ENV=test<CR>", mode = "n", desc = "Test: nearest" },
			{ "<Leader>tf", ":TestFile RAILS_ENV=test<CR>", mode = "n", desc = "Test: file" },
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
		"mitubaEX/server.nvim",
		event = "BufReadPost",
		-- Server list/logs run on Snacks now (plugins.configs.server_picker),
		-- driving server.nvim's core API directly instead of its telescope
		-- extension. These keys also lazy-load the plugin so the picker can.
		keys = {
			{
				"<Leader>fs",
				function()
					require("plugins.configs.server_picker").servers()
				end,
				desc = "Server list",
			},
			{
				"<Leader>fsl",
				function()
					require("plugins.configs.server_picker").logs()
				end,
				desc = "Server logs",
			},
		},
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
