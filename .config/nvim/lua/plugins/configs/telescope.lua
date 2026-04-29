-- Mirrors telescope.builtin.buffers but pre-filters to terminal buffers.
local function pick_terminal_buffers(opts)
	opts = opts or {}
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local make_entry = require("telescope.make_entry")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

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

	table.sort(bufnrs, function(a, b)
		return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
	end)

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
			prompt_title = "🖥  Terminal Buffers",
			finder = finders.new_table({
				results = buffers,
				entry_maker = opts.entry_maker or make_entry.gen_from_buffer(opts),
			}),
			sorter = conf.generic_sorter(opts),
			previewer = conf.grep_previewer(opts),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
						vim.api.nvim_set_current_buf(entry.bufnr)
					end
				end)
				return true
			end,
		})
		:find()
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
	vim.keymap.set("n", ";", "<cmd>Telescope buffers<CR>", { noremap = true, silent = false })
	vim.api.nvim_create_user_command("TelescopeTerminals", function()
		pick_terminal_buffers()
	end, { desc = "Telescope picker over terminal buffers only" })
	vim.keymap.set("n", "<Leader>;", function()
		pick_terminal_buffers()
	end, { noremap = true, silent = true, desc = "Telescope: terminal buffers only" })
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
