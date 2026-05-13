local M = {}

local function input(prompt, on_confirm)
	vim.ui.input({ prompt = prompt }, function(value)
		if not value or value == "" then
			return
		end
		on_confirm(value)
	end)
end

-- Run `action` in a fresh tab whose cwd is the resulting worktree.
-- The current tab is pinned with :tcd first so the global :cd done by
-- GitWorktreeCreate doesn't drag it along.
local function in_new_tab(action)
	vim.cmd("tcd " .. vim.fn.fnameescape(vim.fn.getcwd()))
	vim.cmd("tabnew")
	action()
	vim.cmd("tcd " .. vim.fn.fnameescape(vim.fn.getcwd()))
end

function M.create()
	input("New worktree branch: ", function(branch)
		vim.cmd("GitWorktreeCreate " .. branch)
	end)
end

function M.create_from_default()
	input("New worktree branch (from default): ", function(branch)
		vim.cmd("GitWorktreeCreate " .. branch .. " --from-default")
	end)
end

local function normalize_path(p)
	return (vim.fn.fnamemodify(p, ":p"):gsub("/+$", ""))
end

local function find_tab_for(path)
	local target = normalize_path(path)
	for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnr = vim.api.nvim_tabpage_get_number(tabid)
		local cwd = normalize_path(vim.fn.getcwd(-1, tabnr))
		if cwd == target then
			return tabnr
		end
	end
	return nil
end

local function list_worktrees()
	local out = vim.fn.systemlist("git worktree list")
	if vim.v.shell_error ~= 0 then
		return {}
	end
	local cwd = normalize_path(vim.fn.getcwd())
	local result = {}
	for _, line in ipairs(out) do
		local path, commit, info = line:match("^(.-)%s+(%x+)%s+(.*)$")
		if path and info then
			local branch = info:match("%[(.-)%]") or "HEAD"
			table.insert(result, {
				path = path,
				branch = branch,
				commit = commit,
				display = string.format("%-20s %s", branch, path),
				is_current = normalize_path(path) == cwd,
			})
		end
	end
	return result
end

--- Switch to a tab already pinned to `path`, or open a new tab pinned to it.
function M.switch_to(path, branch)
	local existing = find_tab_for(path)
	if existing then
		vim.cmd(existing .. "tabnext")
		return
	end
	vim.cmd("tcd " .. vim.fn.fnameescape(vim.fn.getcwd()))
	vim.cmd("tabnew")
	vim.api.nvim_set_current_dir(path)
	vim.cmd("tcd " .. vim.fn.fnameescape(path))
	if branch then
		vim.notify("Switched to worktree: " .. path .. " [" .. branch .. "]")
	end
end

function M.switch()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Git Worktrees (tab-aware)",
			finder = finders.new_table({
				results = list_worktrees(),
				entry_maker = function(entry)
					local has_tab = find_tab_for(entry.path) ~= nil
					local prefix
					if entry.is_current then
						prefix = "* "
					elseif has_tab then
						prefix = "T "
					else
						prefix = "  "
					end
					return {
						value = entry,
						display = prefix .. entry.display,
						ordinal = entry.branch .. " " .. entry.path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					if entry then
						M.switch_to(entry.value.path, entry.value.branch)
					end
				end)
				map("i", "<C-d>", function()
					local entry = action_state.get_selected_entry()
					if entry and not entry.value.is_current then
						actions.close(prompt_bufnr)
						require("git_worktree").delete_worktree(entry.value.branch)
					else
						vim.notify("Cannot delete current worktree")
					end
				end)
				return true
			end,
		})
		:find()
end

function M.delete()
	input("Delete worktree branch: ", function(branch)
		vim.cmd("GitWorktreeDelete " .. branch)
	end)
end

function M.review_pr()
	input("Review PR #: ", function(pr)
		in_new_tab(function()
			vim.cmd("GitWorktreeReview " .. pr)
		end)
	end)
end

local function claude()
	return require("plugins.configs.claude_term")
end

function M.create_with_claude()
	input("New worktree branch (+ claude): ", function(branch)
		in_new_tab(function()
			vim.cmd("GitWorktreeCreate " .. branch)
			claude().open()
		end)
	end)
end

function M.create_from_default_with_claude()
	input("New worktree branch (from default + claude): ", function(branch)
		in_new_tab(function()
			vim.cmd("GitWorktreeCreate " .. branch .. " --from-default")
			claude().open()
		end)
	end)
end

function M.review_pr_with_claude()
	input("Review PR # (+ claude --from-pr): ", function(pr)
		in_new_tab(function()
			vim.cmd("GitWorktreeReview " .. pr)
			claude().open({ from_pr = pr })
		end)
	end)
end

local function sanitize_branch(name)
	name = name:gsub('^["`\']+', ""):gsub('["`\']+$', "")
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	-- git refs forbid spaces and many specials; keep only the safe set.
	name = name:gsub("[^A-Za-z0-9_/%-]+", "-")
	name = name:gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	return name
end

local function suggest_branch_name(task, on_done)
	local prompt = table.concat({
		"Suggest ONE short kebab-case git branch name for this task.",
		"Output ONLY the branch name on a single line — no quotes,",
		"no prefix like 'feature/' or 'fix/', no explanation, no markdown fence.",
		"Keep it under 40 characters and ASCII only.",
		"",
		"Task: " .. task,
	}, "\n")

	vim.notify("claude: choosing a branch name…")
	vim.system(
		{ "claude", "-p", prompt },
		{ text = true },
		vim.schedule_wrap(function(out)
			if out.code ~= 0 then
				vim.notify(
					"claude -p failed (exit " .. tostring(out.code) .. "): " .. (out.stderr or ""),
					vim.log.levels.ERROR
				)
				return
			end
			local first
			for line in (out.stdout or ""):gmatch("[^\r\n]+") do
				if line:match("%S") then
					first = line
					break
				end
			end
			local branch = first and sanitize_branch(first) or ""
			if branch == "" then
				vim.notify("claude returned no usable branch name", vim.log.levels.ERROR)
				return
			end
			on_done(branch)
		end)
	)
end

local function create_from_task(from_default)
	local prompt = from_default and "Task (claude picks branch, from default): "
		or "Task (claude picks branch): "
	input(prompt, function(task)
		suggest_branch_name(task, function(branch)
			vim.ui.input({
				prompt = "Create worktree with branch: ",
				default = branch,
			}, function(confirmed)
				if not confirmed or confirmed == "" then
					return
				end
				local create_cmd = "GitWorktreeCreate " .. confirmed
				if from_default then
					create_cmd = create_cmd .. " --from-default"
				end
				in_new_tab(function()
					vim.cmd(create_cmd)
					claude().open({ prompt = task })
				end)
			end)
		end)
	end)
end

function M.create_with_task()
	create_from_task(false)
end

function M.create_from_default_with_task()
	create_from_task(true)
end

return M
