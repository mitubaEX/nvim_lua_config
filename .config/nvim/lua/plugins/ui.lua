return {
	-- syntax
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag",
			"RRethy/nvim-treesitter-endwise",
			"andymass/vim-matchup",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = require("plugins.configs.treesitter"),
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme nightfox")
		end,
	},

	-- editor ui
	{
		"nvim-lualine/lualine.nvim",
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		dependencies = { "kyazdani42/nvim-web-devicons", "ryanoasis/vim-devicons" },
		config = require("plugins.configs.lualine"),
	},
	{
		"stevearc/oil.nvim",
		event = "BufReadPost",
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- `-` opens oil at the current file's parent dir (oil's idiomatic entry
		-- point); previously oil had a full config but no way to open it.
		keys = {
			{ "-", "<cmd>Oil<cr>", mode = "n", desc = "Oil: open parent dir" },
		},
		config = require("plugins.configs.oil"),
	},
	-- {
	-- 	"lukas-reineke/indent-blankline.nvim",
	-- 	main = "ibl",
	-- 	event = "BufReadPost",
	-- 	---@module "ibl"
	-- 	---@type ibl.config
	-- 	opts = {},
	-- },
	{
		"b0o/incline.nvim",
		event = "BufReadPost",
		opts = {},
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = require("plugins.configs.bufferline"),
	},
	{
		"mitubaEX/midori.nvim",
		ft = "markdown",
		cmd = { "MidoriView", "MidoriToggle", "MidoriClose" },
		keys = {
			{ "<leader>mv", "<cmd>MidoriView<cr>", desc = "Midori: view markdown" },
			{ "<leader>mt", "<cmd>MidoriToggle<cr>", desc = "Midori: toggle reader" },
		},
		opts = {},
	},
}
