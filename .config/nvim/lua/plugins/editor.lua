return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
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
		event = { "BufReadPost", "BufWritePost" },
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
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		-- opts + config (including the Snacks-backed picker registration) live in
		-- plugins.configs.snacks to keep this spec thin.
		opts = require("plugins.configs.snacks").opts,
		config = require("plugins.configs.snacks").config,
	},
	{
		"kylechui/nvim-surround",
		event = "InsertEnter",
	},
	{
		"tyru/columnskip.vim",
		event = "VeryLazy",
		config = function()
			vim.keymap.set(
				"n",
				"<Leader>j",
				"<Plug>(columnskip:nonblank:next)",
				{ noremap = false, silent = true, desc = "Column skip down (non-blank)" }
			)
			vim.keymap.set(
				"n",
				"<Leader>k",
				"<Plug>(columnskip:nonblank:prev)",
				{ noremap = false, silent = true, desc = "Column skip up (non-blank)" }
			)
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
			vim.keymap.set(
				"n",
				"<Leader>an",
				":AnyJump<CR>",
				{ noremap = true, silent = false, desc = "AnyJump: jump to definition" }
			)
		end,
	},
	{
		"t9md/vim-quickhl",
		event = "BufReadPost",
		keys = {
			{ "<Leader>h", "<Plug>(quickhl-manual-this)", mode = "n", desc = "Quickhl: highlight word" },
			{ "<Leader>H", "<Plug>(quickhl-manual-reset)", mode = "n", desc = "Quickhl: clear" },
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
		config = function()
			require("substitute").setup()
		end,
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
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<Leader>s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			preset = "modern",
			spec = {
				{ "<leader>c", group = "claude" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>gw", group = "worktree" },
				{ "<leader>s", group = "flash" },
				{ "<leader>t", group = "test" },
				{ "<leader>x", group = "trouble" },
				{ "<leader>a", group = "any-jump" },
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Keymaps (which-key)",
			},
		},
	},
	{
		"folke/todo-comments.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next TODO",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Prev TODO",
			},
			{ "<Leader>xt", "<cmd>Trouble todo<cr>", desc = "TODO (Trouble)" },
		},
	},
}
