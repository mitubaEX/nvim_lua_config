return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		dependencies = {
			{ "j-hui/fidget.nvim", tag = "legacy" },
		},
		config = require("plugins.configs.lspconfig"),
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "InsertEnter",
		opts = {},
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
		},
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls",
					"yamlls",
					"rust_analyzer",
					"pyright",
					"gopls",
					"denols",
					"lua_ls",
				},
				automatic_enable = true,
			})
		end,
	},
	-- ## each langauge
	-- js
	{
		"neoclide/vim-jsx-improve",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},

	-- rails
	{
		"tpope/vim-rails",
		ft = "ruby",
	},

	-- markdown
	{
		"lukas-reineke/headlines.nvim",
		ft = "markdown",
		config = function()
			require("headlines").setup()
		end,
	},
}
