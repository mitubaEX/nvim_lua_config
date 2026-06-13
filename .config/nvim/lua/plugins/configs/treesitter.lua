-- nvim-treesitter config, extracted from plugins/ui.lua.
return function()
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
end
