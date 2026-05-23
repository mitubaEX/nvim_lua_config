-- Telescope config.
--
-- Post Snacks migration telescope only backs the worktree pickers
-- (plugins.configs.worktree) and the git_worktree / server extensions, both of
-- which are telescope-specific extensions shipped by external plugins and have
-- no Snacks equivalent. File/grep/buffer pickers moved to Snacks
-- (plugins.configs.pickers), so telescope loads lazily (cmd/keys) and this
-- config runs the first time it is needed.
return function()
	local actions = require("telescope.actions")
	local mappings = {
		i = {
			["<c-p>"] = actions.cycle_history_prev,
			["<c-n>"] = actions.cycle_history_next,

			["<c-u>"] = actions.preview_scrolling_up,
			["<c-d>"] = actions.preview_scrolling_down,
		},
		n = {
			["<esc>"] = actions.close,

			["<c-u>"] = actions.preview_scrolling_up,
			["<c-d>"] = actions.preview_scrolling_down,
		},
	}

	require("telescope").setup({
		defaults = {
			-- please install fzy
			file_sorter = require("telescope.sorters").get_fzy_sorter,
			generic_sorter = require("telescope.sorters").get_fzy_sorter,
			mappings = mappings,
		},
	})

	-- Telescope-only extensions (no Snacks equivalent). Requiring the extension
	-- triggers lazy.nvim to load the providing plugin, so this works even though
	-- both are lazy.
	require("telescope").load_extension("git_worktree")
	require("telescope").load_extension("server")
end
