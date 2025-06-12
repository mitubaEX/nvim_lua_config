return {
	-- syntax
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		dependencies = { "windwp/nvim-ts-autotag", "RRethy/nvim-treesitter-endwise", "andymass/vim-matchup" },
		build = ":TSUpdate",
		config = function()
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
					"lua",
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
							require("telescope.builtin").find_files({
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
        {
                "lukas-reineke/indent-blankline.nvim",
                event = "BufReadPost",
                ---@module "ibl"
                ---@type ibl.config
                opts = {
                        scope = {
                                show_extra_scope = true,
                        },
                },
        },
        {
                "b0o/incline.nvim",
                event = "BufReadPost",
                opts = {},
        },

	-- startify
        {
                "goolord/alpha-nvim",
                event = "BufWinEnter",
                dependencies = { "kyazdani42/nvim-web-devicons" },
                config = function()
                        local startify = require("alpha.themes.startify")
                        require("alpha").setup(startify.opts)
                end,
        },
}
