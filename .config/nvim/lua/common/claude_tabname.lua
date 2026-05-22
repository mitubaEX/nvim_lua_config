-- Reflect the running claude session in the *outer* terminal's tab/window title
-- via OSC 0 + OSC 2.
--
-- Layout assumption (see plugins/configs/worktree.lua): one git worktree per
-- nvim tab, with claude_workflow.nvim running at most one `claude://<cwd>`
-- :terminal per worktree. The OS terminal shows a single tab for this nvim, so
-- the title tracks the *focused* nvim tab:
--   🤖 <branch>   a claude session is live in the focused tab
--   🔔 <branch>   that session has gone idle / needs attention (claude_workflow
--                 notify.pending)
--   <branch>      no claude session in the focused tab
--
-- We emit BOTH OSC 0 (icon name + window title) and OSC 2 (window title): some
-- terminals map OSC 0/1 to the tab label and OSC 2 to the window title, so
-- sending both maximizes how many places pick the name up.
--
-- Disable entirely with `vim.g.claude_tabname = false`.

local M = {}

local RUNNING = "🤖"
local ATTENTION = "🔔"

-- OSC string terminator. BEL (\7) is the most widely supported across
-- terminals and tmux; ST (ESC \) would also work.
local BEL = "\7"
local ESC = "\27"

--- Build the raw OSC 0 + OSC 2 byte string that sets the terminal's icon name +
--- window title (OSC 0) and window title (OSC 2) to `text`. Pure (no I/O) so it
--- is unit-testable.
--- @param text string|nil
--- @return string
function M.osc(text)
	text = tostring(text or "")
	return ESC .. "]0;" .. text .. BEL .. ESC .. "]2;" .. text .. BEL
end

--- Compose the title from a branch and a session state.
--- @param branch string
--- @param state string|nil "running" | "attention" | nil
--- @return string
function M.compose(branch, state)
	if state == "attention" then
		return ATTENTION .. " " .. branch
	elseif state == "running" then
		return RUNNING .. " " .. branch
	end
	return branch
end

local function normalize_path(p)
	return (vim.fn.fnamemodify(p, ":p"):gsub("/+$", ""))
end

-- Branch name is stable per worktree, so cache the (one) git call per cwd to
-- keep TabEnter / the poll timer cheap.
local branch_cache = {}

--- Branch for `cwd`, falling back to the worktree directory's basename when git
--- can't answer (bare dir, detached HEAD, git missing).
--- @param cwd string
--- @return string
function M.branch_for(cwd)
	cwd = normalize_path(cwd)
	local cached = branch_cache[cwd]
	if cached ~= nil then
		return cached
	end
	local out = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD" })
	local branch
	if vim.v.shell_error == 0 and out[1] and out[1] ~= "" and out[1] ~= "HEAD" then
		branch = out[1]
	else
		branch = vim.fn.fnamemodify(cwd, ":t")
	end
	branch_cache[cwd] = branch
	return branch
end

-- The claude terminal buffer for a cwd is named `claude://<cwd>` by
-- claude_workflow.term; find it (valid) for the given cwd.
local function claude_buf_for(cwd)
	local target = normalize_path(cwd)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) then
			local path = vim.api.nvim_buf_get_name(buf):match("^claude://(.+)$")
			if path and normalize_path(path) == target then
				return buf
			end
		end
	end
	return nil
end

-- claude_workflow may be lazy-loaded; query its pending() flag defensively.
local function pending(cwd)
	local ok, mod = pcall(require, "claude_workflow")
	if ok and type(mod.pending) == "function" then
		return mod.pending(cwd) and true or false
	end
	return false
end

--- The title for the currently focused nvim tab.
--- @return string
function M.current_title()
	local cwd = vim.fn.getcwd()
	local branch = M.branch_for(cwd)
	local state
	if claude_buf_for(cwd) then
		state = pending(cwd) and "attention" or "running"
	end
	return M.compose(branch, state)
end

-- Only write to a real terminal: skip headless nvim (tests, `claude -p`
-- subprocesses) where no UI is attached and there is nothing to title.
local function can_emit()
	return vim.g.claude_tabname ~= false and #vim.api.nvim_list_uis() > 0
end

local function write_raw(s)
	local ok, tty = pcall(io.open, "/dev/tty", "w")
	if ok and tty then
		tty:write(s)
		tty:close()
	end
end

local last_written

--- Recompute the title and emit it only when it changed (avoids spamming the
--- terminal from the poll timer).
function M.update()
	if not can_emit() then
		return
	end
	local title = M.current_title()
	if title == last_written then
		return
	end
	last_written = title
	write_raw(M.osc(title))
end

function M.setup()
	if vim.g.claude_tabname == false then
		return
	end

	local group = vim.api.nvim_create_augroup("ClaudeTabname", { clear = true })

	-- Instant updates on the obvious transitions.
	vim.api.nvim_create_autocmd(
		{ "VimEnter", "TabEnter", "BufEnter", "TermOpen", "TermClose", "DirChanged" },
		{ group = group, callback = M.update }
	)

	-- The 🤖→🔔 flip happens inside claude_workflow.notify on its own idle timer
	-- (no autocmd we can hook), so poll once a second and emit only on change.
	local timer = (vim.uv or vim.loop).new_timer()
	if timer then
		timer:start(1000, 1000, vim.schedule_wrap(M.update))
	end

	-- Best-effort restore on exit: drop the emoji prefix back to the bare dir
	-- name. The shell's prompt usually retitles on the next command anyway.
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			if can_emit() then
				write_raw(M.osc(vim.fn.fnamemodify(vim.fn.getcwd(), ":t")))
			end
		end,
	})

	M.update()
end

M.setup()

return M
