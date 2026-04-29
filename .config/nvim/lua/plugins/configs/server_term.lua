-- Per-cwd server :terminal manager.
-- Mirrors claude_term.lua: each cwd (typically a worktree) gets at most one
-- server terminal, so each branch keeps its own dev server isolated.

local M = {}

-- cwd -> { buf = number, job_id = number, cmd = string }
local terms = {}

local function find_existing(cwd)
	local entry = terms[cwd]
	if not entry then
		return nil
	end
	if not vim.api.nvim_buf_is_valid(entry.buf) then
		terms[cwd] = nil
		return nil
	end
	return entry
end

local function open_split()
	vim.cmd("botright split")
	vim.cmd("resize 15")
end

local function focus(buf)
	local wins = vim.fn.win_findbuf(buf)
	if #wins > 0 then
		vim.api.nvim_set_current_win(wins[1])
		return true
	end
	return false
end

--- Pick the command to run: explicit arg > last cmd in cwd > vim.g default.
function M.resolve_cmd(cmd)
	if cmd and cmd ~= "" then
		return cmd
	end
	local cwd = vim.fn.getcwd()
	local entry = terms[cwd]
	if entry and entry.cmd and entry.cmd ~= "" then
		return entry.cmd
	end
	if type(vim.g.worktree_server_cmd) == "string" and vim.g.worktree_server_cmd ~= "" then
		return vim.g.worktree_server_cmd
	end
	return nil
end

--- Last command run for the current cwd, or nil.
function M.last_cmd()
	local entry = terms[vim.fn.getcwd()]
	return entry and entry.cmd or nil
end

--- Start a server for the current cwd. Focuses the existing terminal if one
--- is already running here.
function M.start(cmd)
	local cwd = vim.fn.getcwd()
	local entry = find_existing(cwd)
	if entry then
		if not focus(entry.buf) then
			open_split()
			vim.api.nvim_win_set_buf(0, entry.buf)
		end
		return
	end

	local resolved = M.resolve_cmd(cmd)
	if not resolved then
		vim.api.nvim_err_writeln("No server command. Pass one or set g:worktree_server_cmd")
		return
	end

	open_split()
	-- Fresh buffer so termopen attaches to it, not whatever the split inherited.
	vim.cmd("enew")
	local job_id = vim.fn.jobstart(resolved, { cwd = cwd, term = true })
	if job_id <= 0 then
		vim.api.nvim_err_writeln("Failed to start server (job_id=" .. job_id .. ")")
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	pcall(vim.api.nvim_buf_set_name, buf, "server://" .. cwd)
	terms[cwd] = { buf = buf, job_id = job_id, cmd = resolved }

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		once = true,
		callback = function()
			terms[cwd] = nil
		end,
	})
end

--- Stop the server for the current cwd.
function M.stop()
	local cwd = vim.fn.getcwd()
	local entry = find_existing(cwd)
	if not entry then
		return
	end
	pcall(vim.fn.jobstop, entry.job_id)
	pcall(vim.api.nvim_buf_delete, entry.buf, { force = true })
	terms[cwd] = nil
end

--- Restart with the last cmd (or the supplied one).
function M.restart(cmd)
	local cwd = vim.fn.getcwd()
	local previous = terms[cwd] and terms[cwd].cmd or nil
	M.stop()
	M.start(cmd or previous)
end

--- Toggle terminal visibility. If not running, starts it.
function M.toggle()
	local cwd = vim.fn.getcwd()
	local entry = find_existing(cwd)
	if entry then
		local wins = vim.fn.win_findbuf(entry.buf)
		if #wins > 0 then
			if #vim.api.nvim_list_wins() == 1 then
				return
			end
			for _, w in ipairs(wins) do
				if vim.api.nvim_win_is_valid(w) then
					vim.api.nvim_win_close(w, false)
				end
			end
			return
		end
		open_split()
		vim.api.nvim_win_set_buf(0, entry.buf)
		return
	end
	M.start()
end

--- Whether a server is currently running in the cwd.
function M.is_running()
	return find_existing(vim.fn.getcwd()) ~= nil
end

return M
