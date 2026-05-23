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
		config = function()
			-- archived nvim-treesitter master の query_predicates が Neovim 0.10+ の
			-- TSMatch 新形式 (TSNode[]) に未対応で、vim-matchup 経由で E5108 が出るため
			-- 該当 directive を上書きする。
			require("config.treesitter_compat").apply()

			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"ruby",
					"javascript",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"typescript",
					"tsx",
					"json",
					"yaml",
					"html",
					"css",
					"scss",
					"bash",
					"python",
					"go",
					"rust",
					"toml",
					"jsonc",
					"dockerfile",
				},
				sync_install = false,
				auto_install = true,
				ignore_install = {},
				modules = {},
				matchup = {
					enable = true, -- mandatory, false will disable the whole extension
				},
				autotag = {
					enable = true,
				},
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
				},
				endwise = {
					enable = true,
				},
				textobjects = {
					move = {
						enable = true,
						set_jumps = true,
					},
					select = {
						enable = true,
						lookahead = true,
					},
				},
			})
		end,
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
		config = function()
			local oil = require("oil")

			oil.setup({
				keymaps = {
					["q"] = { "actions.close", mode = "n" },
					["<C-d>"] = "actions.preview_scroll_down",
					["<C-u>"] = "actions.preview_scroll_up",
					["<leader>ff"] = {
						function()
							Snacks.picker.files({
								cwd = require("oil").get_current_dir(),
							})
						end,
						mode = "n",
						nowait = true,
						desc = "Find files in the current directory",
					},
				},
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "OilEnter",
				callback = vim.schedule_wrap(function(args)
					if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
						oil.open_preview()
					end
				end),
			})
		end,
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
	-- Tab page bar: shows Vim tabs (each tab ≈ a worktree in this config).
	-- Labels render the tab's cwd basename so a worktree tab reads as the
	-- branch/dir name (e.g. `add_tab_bar_plugin`) instead of the active buffer.
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				mode = "tabs",
				style_preset = "default",
				-- Prefix each tab with its ordinal (1., 2., …) so it doubles as
				-- the `<n>gt` target. In tabs mode the ordinal equals the tab's
				-- position, i.e. the number Vim uses for `:tabnext`.
				numbers = "ordinal",
				diagnostics = "nvim_lsp",
				show_buffer_close_icons = false,
				show_close_icon = false,
				separator_style = "thin",
				always_show_bufferline = true,
				indicator = { style = "underline" },
				name_formatter = function(opts)
					-- Closing a tab can cause bufferline to re-render with a
					-- stale `tabnr` that no longer exists. `vim.fn.getcwd(-1, tabnr)`
					-- raises E5000 in that case, surfacing as E5108. Guard with a
					-- range check and pcall, falling back to the buffer name.
					local tabnr = opts.tabnr
					if tabnr and tabnr >= 1 and tabnr <= vim.fn.tabpagenr("$") then
						local ok, cwd = pcall(vim.fn.getcwd, -1, tabnr)
						if ok then
							local label = vim.fn.fnamemodify(cwd, ":t")
							if label ~= "" then
								local ok_notif, notif = pcall(require, "claude_workflow")
								if ok_notif and notif.pending(cwd) then
									label = "● " .. label
								end
								return label
							end
						end
					end
					return opts.name
				end,
			},
		},
	},
}
