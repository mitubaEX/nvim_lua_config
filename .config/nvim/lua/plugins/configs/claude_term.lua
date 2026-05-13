-- Per-cwd Claude :terminal manager.
-- Each cwd (typically a worktree) gets at most one claude terminal buffer,
-- so switching worktrees keeps each session isolated.

local M = {}

-- cwd -> { buf = number, job_id = number }
local terms = {}

local function current_branch()
	local out = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")
	if vim.v.shell_error ~= 0 or not out[1] then
		return nil
	end
	return out[1]
end

local function build_cmd(opts)
	local parts = { "claude" }
	if opts.continue then
		table.insert(parts, "-c")
	end
	if opts.resume then
		table.insert(parts, "-r")
		if type(opts.resume) == "string" and opts.resume ~= "" then
			table.insert(parts, vim.fn.shellescape(opts.resume))
		end
	end
	if opts.from_pr then
		table.insert(parts, "--from-pr")
		if type(opts.from_pr) == "string" and opts.from_pr ~= "" then
			table.insert(parts, vim.fn.shellescape(opts.from_pr))
		elseif type(opts.from_pr) == "number" then
			table.insert(parts, tostring(opts.from_pr))
		end
	end
	if opts.append_system_prompt and opts.append_system_prompt ~= "" then
		table.insert(parts, "--append-system-prompt")
		table.insert(parts, vim.fn.shellescape(opts.append_system_prompt))
	end
	if opts.name and opts.name ~= "" then
		table.insert(parts, "-n")
		table.insert(parts, vim.fn.shellescape(opts.name))
	end
	if opts.prompt and opts.prompt ~= "" then
		table.insert(parts, vim.fn.shellescape(opts.prompt))
	end
	return table.concat(parts, " ")
end

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
	vim.cmd("botright vsplit")
	vim.cmd("vertical resize 80")
end

--- Open (or focus) a claude terminal for the current cwd.
--- @param opts table|nil { prompt, continue, resume, from_pr, append_system_prompt, name, no_split }
--- `no_split = true` reuses the current window instead of opening a vsplit
--- (used by the worktree-tab flow where the new tab already exists for claude).
function M.open(opts)
	opts = opts or {}
	local cwd = vim.fn.getcwd()
	local entry = find_existing(cwd)

	if entry then
		local wins = vim.fn.win_findbuf(entry.buf)
		if #wins > 0 then
			vim.api.nvim_set_current_win(wins[1])
		else
			if not opts.no_split then
				open_split()
			end
			vim.api.nvim_win_set_buf(0, entry.buf)
		end
		vim.cmd("startinsert")
		return
	end

	if opts.name == nil then
		opts.name = current_branch()
	end

	if not opts.no_split then
		open_split()
	end
	-- Need a fresh buffer for the terminal; the split (or tab) inherited the previous one.
	vim.cmd("enew")
	local cmd = build_cmd(opts)
	local job_id = vim.fn.jobstart(cmd, { cwd = cwd, term = true })
	if job_id <= 0 then
		vim.api.nvim_err_writeln("Failed to start claude (job_id=" .. job_id .. ")")
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	pcall(vim.api.nvim_buf_set_name, buf, "claude://" .. cwd)
	terms[cwd] = { buf = buf, job_id = job_id }

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		once = true,
		callback = function()
			terms[cwd] = nil
		end,
	})

	vim.cmd("startinsert")
end

--- Toggle visibility of the claude terminal for the current cwd.
function M.toggle()
	local cwd = vim.fn.getcwd()
	local entry = find_existing(cwd)
	if entry then
		local wins = vim.fn.win_findbuf(entry.buf)
		if #wins > 0 then
			if #vim.api.nvim_list_wins() == 1 then
				-- Only window — don't close, just leave it
				return
			end
			for _, w in ipairs(wins) do
				if vim.api.nvim_win_is_valid(w) then
					vim.api.nvim_win_close(w, false)
				end
			end
			return
		end
	end
	M.open()
end

--- Kill the claude terminal for the current cwd.
function M.kill()
	local cwd = vim.fn.getcwd()
	local entry = find_existing(cwd)
	if not entry then
		return
	end
	pcall(vim.api.nvim_buf_delete, entry.buf, { force = true })
	terms[cwd] = nil
end

--- Send text to the claude terminal for the current cwd.
--- Opens a new session with the text as the initial prompt if none exists.
function M.send(text)
	if not text or text == "" then
		return
	end
	local cwd = vim.fn.getcwd()
	local entry = find_existing(cwd)
	if not entry then
		M.open({ prompt = text })
		return
	end
	vim.fn.chansend(entry.job_id, text .. "\r")
	local wins = vim.fn.win_findbuf(entry.buf)
	if #wins > 0 then
		vim.api.nvim_set_current_win(wins[1])
		vim.cmd("startinsert")
	end
end

return M
