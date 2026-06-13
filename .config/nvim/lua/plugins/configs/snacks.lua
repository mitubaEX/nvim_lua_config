-- snacks.nvim config, extracted from plugins/editor.lua to keep the spec thin
-- and match the configs/ module layout used by lspconfig/lualine/pickers.
--
-- Snacks is loaded at startup (lazy = false), so the Snacks-backed pickers and
-- the per-tab buffer tracking they rely on are registered here via
-- plugins.configs.pickers. telescope is fully removed: every picker
-- (files/grep/buffers, worktrees) now runs on Snacks.picker.
local M = {}

M.opts = {
	bufdelete = { enabled = true },
	dashboard = { enabled = false },
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
}

function M.config(_, opts)
	require("snacks").setup(opts)
	require("plugins.configs.pickers").setup()
end

return M
