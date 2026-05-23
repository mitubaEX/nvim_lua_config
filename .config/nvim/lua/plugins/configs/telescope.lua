local tab_buffers = require("plugins.configs.tab_buffers")

-- Open a telescope buffer picker over an explicit bufnr list. Mirrors
-- telescope.builtin.buffers, which has no per-tab or terminal filter, so callers
-- decide exactly which buffers to show.
local function pick_buffers(bufnrs, opts)
	opts = opts or {}
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local make_entry = require("telescope.make_entry")

	table.sort(bufnrs, function(a, b)
		return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
	end)

	-- gen_from_buffer reads opts.bufnr_width to align the bufnr column;
	-- telescope.builtin.buffers precomputes it, so a standalone picker must too
	-- or the finder dies with "bufnr_width (a nil value)".
	if not opts.bufnr_width then
		local max_bufnr = 0
		for _, b in ipairs(bufnrs) do
			max_bufnr = math.max(max_bufnr, b)
		end
		opts.bufnr_width = #tostring(max_bufnr)
	end

	local current = vim.api.nvim_get_current_buf()
	local alternate = vim.fn.bufnr("#")
	local buffers = {}
	for _, bufnr in ipairs(bufnrs) do
		local flag = bufnr == current and "%" or (bufnr == alternate and "#" or " ")
		table.insert(buffers, {
			bufnr = bufnr,
			flag = flag,
			info = vim.fn.getbufinfo(bufnr)[1],
		})
	end

	pickers
		.new(opts, {
			prompt_title = opts.prompt_title or "Buffers",
			finder = finders.new_table({
				results = buffers,
				entry_maker = opts.entry_maker or make_entry.gen_from_buffer(opts),
			}),
			sorter = conf.generic_sorter(opts),
			previewer = conf.grep_previewer(opts),
		})
		:find()
end

-- Picker scoped to terminal buffers only, since telescope has no native
-- terminal filter.
local function pick_terminal_buffers(opts)
	opts = opts or {}
	local bufnrs = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "terminal" then
			table.insert(bufnrs, b)
		end
	end
	if not next(bufnrs) then
		vim.notify("No terminal buffers", vim.log.levels.INFO)
		return
	end
	opts.prompt_title = opts.prompt_title or "🖥  Terminal Buffers"
	pick_buffers(bufnrs, opts)
end

-- Picker scoped to the current tab's buffers (see plugins.configs.tab_buffers).
local function pick_tab_buffers(opts)
	opts = opts or {}
	local bufnrs = tab_buffers.current_tab_bufnrs()
	if not next(bufnrs) then
		vim.notify("No buffers in this tab", vim.log.levels.INFO)
		return
	end
	opts.prompt_title = opts.prompt_title or "✨ Buffers (this tab) ✨"
	pick_buffers(bufnrs, opts)
end

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
	-- Track per-tab buffer membership so `;` can scope to the current tab.
	tab_buffers.setup()

	-- Global remapping
	------------------------------
	require("telescope").setup({
		defaults = {
			-- please install fzy
			file_sorter = require("telescope.sorters").get_fzy_sorter,
			generic_sorter = require("telescope.sorters").get_fzy_sorter,
			mappings = mappings,
		},
		pickers = {
			-- Your special builtin config goes in here
			buffers = {
				prompt_title = "✨ Search Buffers ✨",
				mappings = mappings,
				sort_mru = true,
				preview_title = false,
				-- theme = "ivy",
			},
			git_files = {
				mappings = mappings,
				sort_mru = true,
				preview_title = false,
				prompt_title = "",
				prompt_prefix = "     ",
				selection_caret = "  ",
				entry_prefix = "  ",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.80,
					height = 0.85,
					preview_cutoff = 120,
				},
				winblend = 0,
				set_env = { ["COLORTERM"] = "truecolor" },
				selection_strategy = "reset",
				results_title = "",
				color_devicons = true,
				use_less = true,
				-- ignore rbi
				file_ignore_patterns = { "%.rbi" },
			},
			grep_string = {
				mappings = mappings,
				file_ignore_patterns = { "%.rbi" },
			},
			live_grep = {
				additional_args = function()
					return { "--hidden" }
				end,
				file_ignore_patterns = { "%.rbi" },
			},
			registers = {
				mappings = mappings,
				-- theme="ivy",
			},
			git_bcommits = {
				mappings = mappings,
				theme = "ivy",
			},
		},
	})

	-- vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope git_files<CR>", { noremap = true, silent = false })
	vim.keymap.set("n", "<Leader>ff", "<cmd>lua Snacks.picker.git_files()<CR>", { noremap = true, silent = false })
	-- vim.keymap.set("n", "<Leader>fg", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = false })
	vim.keymap.set(
		"n",
		"<Leader>fg",
		"<cmd>lua Snacks.picker.grep({ hidden = true })<CR>",
		{ noremap = true, silent = false }
	)
	-- `;` lists only the current tab's buffers (own implementation, not
	-- telescope's path-based cwd_only) so worktree tabs don't bleed into each
	-- other even when they share a cwd.
	vim.keymap.set("n", ";", function()
		pick_tab_buffers()
	end, { noremap = true, silent = true, desc = "Buffers in current tab" })
	vim.api.nvim_create_user_command("TelescopeTerminals", function()
		pick_terminal_buffers()
	end, { desc = "Telescope picker over terminal buffers only" })
	vim.keymap.set("n", "<Leader>;", function()
		pick_terminal_buffers()
	end, { noremap = true, silent = true, desc = "Telescope: terminal buffers" })
	-- vim.keymap.set(
	-- 	"n",
	-- 	";",
	-- 	"<cmd>lua Snacks.picker.buffers({ hidden = true })<CR>",
	-- 	{ noremap = true, silent = false }
	-- )

	-- load telescope extensions
	require("telescope").load_extension("git_worktree")
	require("telescope").load_extension("server")
end
