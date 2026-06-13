-- Snacks-based pickers, registered at startup.
--
-- The file/grep pickers and the `;` / terminal buffer pickers all run on
-- Snacks.picker. telescope has been fully removed; the worktree
-- (plugins.configs.worktree) picker is on Snacks too. These keymaps must be
-- bound at startup, which is why they live here. Snacks is `lazy = false`, so
-- `Snacks.picker.*` is always available by the time a key is pressed.
local tab_buffers = require("plugins.configs.tab_buffers")

local M = {}

-- Snacks.picker.buffers has no per-tab or terminal scoping, so we hand it an
-- explicit allowlist of bufnrs through its `filter.filter` predicate. The
-- buffers finder applies the predicate to every candidate, so only allowlisted
-- buffers survive. `hidden = true` keeps the allowlist (not buflisted-ness) the
-- sole authority over what shows.
local function pick_allowed(wanted, opts)
	return Snacks.picker.buffers(vim.tbl_extend("force", {
		hidden = true,
		sort_lastused = true,
		filter = {
			filter = function(item)
				return wanted[item.buf] == true
			end,
		},
	}, opts or {}))
end

-- Picker scoped to the current tab's buffers (see plugins.configs.tab_buffers).
function M.pick_tab_buffers()
	local wanted = {}
	for _, b in ipairs(tab_buffers.current_tab_bufnrs()) do
		wanted[b] = true
	end
	if not next(wanted) then
		vim.notify("No buffers in this tab", vim.log.levels.INFO)
		return
	end
	pick_allowed(wanted, { title = "Buffers (this tab)" })
end

-- Picker scoped to terminal buffers only.
function M.pick_terminal_buffers()
	local wanted = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "terminal" then
			wanted[b] = true
		end
	end
	if not next(wanted) then
		vim.notify("No terminal buffers", vim.log.levels.INFO)
		return
	end
	pick_allowed(wanted, { title = "Terminal Buffers", nofile = true })
end

-- Register the Snacks-backed pickers + per-tab buffer tracking. Idempotent.
function M.setup()
	-- Track per-tab buffer membership so `;` can scope to the current tab.
	tab_buffers.setup()

	vim.keymap.set("n", "<Leader>ff", function()
		Snacks.picker.git_files()
	end, { noremap = true, silent = true, desc = "Find git files" })
	vim.keymap.set("n", "<Leader>fg", function()
		Snacks.picker.grep({ hidden = true })
	end, { noremap = true, silent = true, desc = "Live grep" })

	-- Open the current file/line on the git host (snacks gitbrowse is enabled but
	-- previously had no keymap).
	vim.keymap.set({ "n", "v" }, "<Leader>go", function()
		Snacks.gitbrowse()
	end, { noremap = true, silent = true, desc = "Git: open in browser" })

	-- `;` lists only the current tab's buffers (own per-tab tracking, not
	-- telescope's path-based cwd_only) so worktree tabs don't bleed into each
	-- other even when they share a cwd.
	vim.keymap.set("n", ";", M.pick_tab_buffers, {
		noremap = true,
		silent = true,
		desc = "Buffers in current tab",
	})
	vim.keymap.set("n", "<Leader>;", M.pick_terminal_buffers, {
		noremap = true,
		silent = true,
		desc = "Terminal buffers (Snacks)",
	})
	vim.api.nvim_create_user_command("TerminalBuffers", M.pick_terminal_buffers, {
		desc = "Snacks picker over terminal buffers only",
	})
end

return M
