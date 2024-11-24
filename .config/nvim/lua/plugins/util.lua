return {
	{
		"akinsho/toggleterm.nvim",
		lazy = false,
		config = function()
			require("toggleterm").setup({
				-- size = 60,
				direction = "horizontal",

				-- 2<C-t> to open new terminal
				open_mapping = { [[<c-\>]], [[<C-t>]] },
			})
		end,
		keys = {
			{ "<Leader>tt", "<cmd>lua require('toggleterm').toggle()<CR>", mode = "n" },
		},
	},
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
}
