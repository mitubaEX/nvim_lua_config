-- Per-cwd "needs attention" flag for the claude :terminal in that cwd.
-- Bufferline's name_formatter calls `pending(cwd)` and prepends a marker
-- to the matching tab, so the user can see which worktree's claude has
-- gone idle while they were elsewhere.

local M = {}

-- cwd -> { pending = bool, timer = uv_timer, buf = number }
local state = {}

-- Output is considered "settled" after this many ms of silence — that's when
-- we decide claude has stopped streaming and the user might want to look.
local IDLE_MS = 1500

local augroup = vim.api.nvim_create_augroup("ClaudeNotification", { clear = true })

local function buf_visible_in_current_tab(buf)
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_buf(win) == buf then
			return true
		end
	end
	return false
end

local function set_pending(cwd, val)
	local entry = state[cwd]
	if not entry then
		return
	end
	if entry.pending == val then
		return
	end
	entry.pending = val
	vim.schedule(function()
		pcall(vim.cmd, "redrawtabline")
	end)
end

function M.pending(cwd)
	local entry = state[cwd]
	return entry and entry.pending or false
end

function M.clear(cwd)
	set_pending(cwd, false)
end

local function close_timer(entry)
	if entry and entry.timer then
		entry.timer:stop()
		entry.timer:close()
		entry.timer = nil
	end
end

function M.watch(buf, cwd)
	-- Wipe any prior watcher for this cwd (reuse can happen if a buffer dies
	-- and gets recreated under the same cwd key).
	close_timer(state[cwd])

	local entry = { pending = false, buf = buf, timer = vim.loop.new_timer() }
	state[cwd] = entry

	vim.api.nvim_buf_attach(buf, false, {
		on_lines = function()
			if not entry.timer then
				return
			end
			entry.timer:stop()
			entry.timer:start(
				IDLE_MS,
				0,
				vim.schedule_wrap(function()
					if not vim.api.nvim_buf_is_valid(buf) then
						return
					end
					if buf_visible_in_current_tab(buf) then
						return
					end
					set_pending(cwd, true)
				end)
			)
		end,
		on_detach = function()
			close_timer(entry)
			state[cwd] = nil
			vim.schedule(function()
				pcall(vim.cmd, "redrawtabline")
			end)
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		buffer = buf,
		callback = function()
			set_pending(cwd, false)
		end,
	})
end

-- A single TabEnter handler clears pending for any claude buffer that becomes
-- visible in the newly-entered tab — avoids creating one autocmd per buffer.
vim.api.nvim_create_autocmd("TabEnter", {
	group = augroup,
	callback = function()
		for cwd, entry in pairs(state) do
			if entry.buf and vim.api.nvim_buf_is_valid(entry.buf) and buf_visible_in_current_tab(entry.buf) then
				set_pending(cwd, false)
			end
		end
	end,
})

return M
