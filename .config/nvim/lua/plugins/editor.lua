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
		"nvim-telescope/telescope.nvim",
		lazy = false,
		cmd = "Telescope",
		keys = {
			{ "<Leader>fp", "<cmd>Telescope possession<CR>", desc = "Telescope possession" },
			{ "<Leader>gw", "<cmd>Telescope git_worktree<CR>", desc = "Git worktree" },
			{ "<Leader>gwc", ":GitWorktreeCreate", desc = "Git worktree create" },
			{ "<Leader>gwr", ":GitWorktreeReview", desc = "Git worktree review" },
			{ "<Leader>fs", "<cmd>Telescope server servers<CR>", desc = "Server list" },
			{ "<Leader>fsl", "<cmd>Telescope server logs<CR>", desc = "Server logs" },
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		config = require("plugins.configs.telescope"),
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bufdelete = { enabled = true },
			dashboard = { enabled = true },
			gh = { enabled = true },
			git = { enabled = true },
			gitbrowse = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			picker = {
				enabled = true,
				win = {
					input = {
						keys = {
							["<C-p>"] = { "history_back", mode = { "i", "n" } },
							["<C-n>"] = { "history_forward", mode = { "i", "n" } },
						},
					},
				},
			},
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			-- scroll = { enabled = true },
			statuscolumn = { enabled = true },
			terminal = { enabled = true },
			words = { enabled = true },
		},
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
		"jedrzejboczar/possession.nvim",
		event = "BufReadPost",
		opts = {
			autosave = {
				current = true,
				cwd = function()
					return not require("possession.session").exists(require("possession.paths").cwd_session_name())
				end,
			},
			autoload = "auto_cwd",
			plugins = {
				delete_buffers = true,
			},
		},
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
			{ "S", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "<Leader>S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
		},
	},
	{
		"folke/todo-comments.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{ "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
			{ "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
			{ "<Leader>xt", "<cmd>Trouble todo<cr>", desc = "TODO (Trouble)" },
		},
	},
}
