-- Per-tab buffer membership.
--
-- Neovim buffers are global, so a plain buffer list mixes files from every tab.
-- With one worktree per tab (each tab :tcd-pinned), the global `;` list ends up
-- showing files from every worktree at once. Unlike telescope's path-based
-- `cwd_only`, this tracks which buffers were actually visited in each tab, so it
-- scopes correctly even when two tabs share the same cwd.
--
-- A buffer is recorded as belonging to a tab whenever it is entered while that
-- tab is active. `current_tab_bufnrs()` returns that set (plus whatever is
-- currently shown in the tab's windows, so the list stays correct for buffers
-- opened before tracking started, e.g. on lazy load).
local M = {}

-- [tabpage handle] -> { [bufnr] = true }
local tab_bufs = {}

local function is_real(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

-- Record `bufnr` as a member of `tabpage`.
local function record(tabpage, bufnr)
	if not is_real(bufnr) then
		return
	end
	local set = tab_bufs[tabpage]
	if not set then
		set = {}
		tab_bufs[tabpage] = set
	end
	set[bufnr] = true
end

-- Drop state for tabpages that no longer exist.
local function prune_tabs()
	local alive = {}
	for _, t in ipairs(vim.api.nvim_list_tabpages()) do
		alive[t] = true
	end
	for t in pairs(tab_bufs) do
		if not alive[t] then
			tab_bufs[t] = nil
		end
	end
end

-- Buffers belonging to the current tab. Deduped and validated; ordering is left
-- to the picker. Buffers currently shown in the tab's windows are always
-- included so the list is correct even for buffers opened before tracking began.
function M.current_tab_bufnrs()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local set = {}
	for bufnr in pairs(tab_bufs[tabpage] or {}) do
		set[bufnr] = true
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
		set[vim.api.nvim_win_get_buf(win)] = true
	end
	local result = {}
	for bufnr in pairs(set) do
		if is_real(bufnr) then
			table.insert(result, bufnr)
		end
	end
	table.sort(result)
	return result
end

-- Register the autocmds that maintain per-tab membership. Idempotent.
function M.setup()
	local group = vim.api.nvim_create_augroup("TabScopedBuffers", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = group,
		callback = function(args)
			record(vim.api.nvim_get_current_tabpage(), args.buf)
		end,
	})
	vim.api.nvim_create_autocmd("TabClosed", {
		group = group,
		callback = prune_tabs,
	})
	-- Seed the current tab with whatever is already open at setup time.
	record(vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_buf())
	return M
end

return M
