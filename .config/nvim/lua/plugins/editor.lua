return {
	{
		"stevearc/conform.nvim",
		lazy = false,
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				-- Use a sub-list to run only the first available formatter
				javascript = { "prettierd", "prettier" },
				typescript = { "prettierd", "prettier" },
				go = { "gofmt" },
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		lazy = false,
		config = function()
			require("lint").linters_by_ft = {
				javascript = { "eslint" },
				typescript = { "eslint" },
				lua = { "luacheck" },
				ruby = { "rubocop" },
			}
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		lazy = false,
		dependencies = { "nvim-lua/plenary.nvim" },
		config = require("plugins.configs.telescope"),
	},
	{
		"kylechui/nvim-surround",
		event = "InsertEnter",
	},
	{
		"tyru/columnskip.vim",
		event = "VeryLazy",
		config = function()
			vim.keymap.set("n", "<Leader>j", "<Plug>(columnskip:nonblank:next)", { noremap = false, silent = true })
			vim.keymap.set("n", "<Leader>k", "<Plug>(columnskip:nonblank:prev)", { noremap = false, silent = true })
		end,
	},
	{
		"mg979/vim-visual-multi",
		event = "BufReadPost",
	},

	{
		"pechorin/any-jump.vim",
		event = "BufReadPost",
		init = function()
			vim.g.any_jump_disable_default_keybindings = "1"
		end,
		config = function()
			vim.keymap.set("n", "<Leader>an", ":AnyJump<CR>", { noremap = true, silent = false })
		end,
	},
	{
		"t9md/vim-quickhl",
		event = "BufReadPost",
		keys = {
			{ "<Leader>h", "<Plug>(quickhl-manual-this)", mode = "n" },
			{ "<Leader>H", "<Plug>(quickhl-manual-reset)", mode = "n" },
		},
	},
	{
		"xiyaowong/nvim-cursorword",
		event = "BufReadPost",
		config = function()
			vim.api.nvim_set_hl(0, "CursorWord", { underline = true, default = true })
		end,
	},
	{
		"gbprod/substitute.nvim",
		event = "VeryLazy",
		keys = {
			{ "s", "<cmd>lua require('substitute').operator()<cr>", mode = "n" },
		},
	},
	{
		"bkad/CamelCaseMotion",
		event = "InsertEnter",
		config = function()
			vim.keymap.set("", "w", "<Plug>CamelCaseMotion_w", { noremap = false, silent = true })
			vim.keymap.set("", "e", "<Plug>CamelCaseMotion_e", { noremap = false, silent = true })
			vim.keymap.set("o", "iw", "<Plug>CamelCaseMotion_iw", { noremap = false, silent = true })
			vim.keymap.set("x", "iw", "<Plug>CamelCaseMotion_iw", { noremap = false, silent = true })
			vim.keymap.set("o", "ie", "<Plug>CamelCaseMotion_ie", { noremap = false, silent = true })
			vim.keymap.set("x", "ie", "<Plug>CamelCaseMotion_ie", { noremap = false, silent = true })
		end,
	},
	{
		"Asheq/close-buffers.vim",
		event = { "CursorHold", "CursorHoldI" },
	},
	{
		"phaazon/hop.nvim",
		event = "BufReadPost",
		config = function()
			require("hop").setup({
				keys = "etovxqpdygfblzhckisuran",
				term_seq_bias = 0.5,
				create_hl_autocmd = false,
				winblend = 0,
			})
			vim.keymap.set("n", "<Leader>hp", ":HopWord<CR>", { noremap = true, silent = true })
		end,
	},
	{
		"monaqa/dial.nvim",
		event = "BufReadPost",
		config = function()
			vim.keymap.set("n", "<C-a>", function()
				require("dial.map").manipulate("increment", "normal")
			end)
			vim.keymap.set("n", "<C-x>", function()
				require("dial.map").manipulate("decrement", "normal")
			end)
		end,
	},
	{
		"rhysd/accelerated-jk",
		event = "VeryLazy",
		config = function()
			vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)", { noremap = false, silent = false })
			vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)", { noremap = false, silent = false })
		end,
	},
	{
		"nicwest/vim-camelsnek",
		event = "VeryLazy",
	},
	{
		"rhysd/clever-f.vim",
		event = "VeryLazy",
	},
}
