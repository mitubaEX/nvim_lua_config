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
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		lazy = false,
		config = function()
			require("mason-lspconfig").setup()
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		event = "BufReadPost",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
			"leoluz/nvim-dap-go",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			require("dapui").setup()
			require("dap-go").setup()

			-- デバッグ実行はこれ
			-- local dap = require('dap')
			-- dap.listerners.after.event_initialized['dapui_config'] = dapui.open
			-- dap.listerners.after.event_terminated['dapui_config'] = dapui.close

			-- 単体テストはこれ
			-- lua require('dap-go').debug_test()
		end,
	},

	-- ## each langauge
	-- js
	{
		"neoclide/vim-jsx-improve",
		lazy = false,
	},

	-- rails
	{
		"tpope/vim-rails",
		ft = "ruby",
		dependencies = { "tpope/vim-bundler", "tpope/vim-dispatch" },
	},

	-- markdown
	{
		"lukas-reineke/headlines.nvim",
		ft = "markdown",
		config = function()
			require("headlines").setup()
		end,
	},

	-- AI
	{
		"greggh/claude-code.nvim",
		event = "BufReadPost",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for git operations
		},
		config = function()
			require("claude-code").setup()
		end,
	},
	{
		"azorng/goose.nvim",
		event = "BufReadPost",
		config = function()
			require("goose").setup({})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					anti_conceal = { enabled = false },
				},
			},
		},
	},
}
