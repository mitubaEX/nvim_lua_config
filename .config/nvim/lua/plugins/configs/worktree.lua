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

-- Returns { [branch] = { number, state, isDraft } } from `gh pr list`.
-- Empty on any failure (gh missing, not a GH repo, network down).
local function fetch_prs_by_branch()
	if vim.fn.executable("gh") ~= 1 then
		return {}
	end
	local out = vim.fn.systemlist({
		"gh",
		"pr",
		"list",
		"--state",
		"all",
		"--json",
		"number,headRefName,state,isDraft",
		"--limit",
		"200",
	})
	if vim.v.shell_error ~= 0 then
		return {}
	end
	local ok, decoded = pcall(vim.json.decode, table.concat(out, "\n"))
	if not ok or type(decoded) ~= "table" then
		return {}
	end
	-- gh returns newest first; keep the most recent entry per branch so a
	-- reopened branch shows its current PR rather than an old merged one.
	local by_branch = {}
	for _, pr in ipairs(decoded) do
		if pr.headRefName and not by_branch[pr.headRefName] then
			by_branch[pr.headRefName] = pr
		end
	end
	return by_branch
end

local function format_pr_label(pr)
	if not pr then
		return ""
	end
	if pr.state == "OPEN" then
		return pr.isDraft and string.format("#%d(D)", pr.number) or string.format("#%d", pr.number)
	end
	if pr.state == "MERGED" then
		return string.format("#%d(M)", pr.number)
	end
	-- CLOSED (un-merged): not surfaced.
	return ""
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
	-- One synchronous `gh` call per picker invocation; misses (no gh, offline)
	-- degrade to an empty map and an empty PR column rather than failing.
	local prs = fetch_prs_by_branch()
	local worktrees = list_worktrees()
	if #worktrees == 0 then
		vim.notify("No worktrees found", vim.log.levels.INFO)
		return
	end

	local items = {}
	for _, wt in ipairs(worktrees) do
		local has_tab = find_tab_for(wt.path) ~= nil
		local prefix
		if wt.is_current then
			prefix = "* "
		elseif has_tab then
			prefix = "T "
		else
			prefix = "  "
		end
		local pr_label = format_pr_label(prs[wt.branch])
		table.insert(items, {
			text = wt.branch .. " " .. pr_label .. " " .. wt.path,
			display = string.format("%s%-24s %-8s %s", prefix, wt.branch, pr_label, wt.path),
			worktree = wt,
		})
	end

	Snacks.picker.pick({
		source = "worktrees",
		title = "Git Worktrees (tab-aware)",
		items = items,
		format = function(item)
			return { { item.display } }
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				M.switch_to(item.worktree.path, item.worktree.branch)
			end
		end,
		actions = {
			-- <C-d> deletes the worktree from disk via the git_worktree core API
			-- (the custom picker never used telescope's git_worktree extension).
			delete_worktree = function(picker, item)
				if item and not item.worktree.is_current then
					picker:close()
					require("git_worktree").delete_worktree(item.worktree.branch)
				else
					vim.notify("Cannot delete current worktree")
				end
			end,
		},
		win = {
			input = {
				keys = {
					["<C-d>"] = { "delete_worktree", mode = { "i", "n" } },
				},
			},
		},
	})
end

function M.delete()
	input("Delete worktree branch: ", function(branch)
		vim.cmd("GitWorktreeDelete " .. branch)
	end)
end

-- Build a {normalized cwd -> branch} map from `git worktree list` so the
-- close-tabs picker can show the branch alongside the tab's pinned directory.
local function branch_by_cwd()
	local map = {}
	for _, wt in ipairs(list_worktrees()) do
		map[normalize_path(wt.path)] = wt.branch
	end
	return map
end

local function list_open_tabs()
	local current = vim.api.nvim_tabpage_get_number(vim.api.nvim_get_current_tabpage())
	local branch_for = branch_by_cwd()
	local result = {}
	for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnr = vim.api.nvim_tabpage_get_number(tabid)
		local cwd = vim.fn.getcwd(-1, tabnr)
		local branch = branch_for[normalize_path(cwd)] or "-"
		table.insert(result, {
			tabnr = tabnr,
			cwd = cwd,
			branch = branch,
			basename = vim.fn.fnamemodify(cwd, ":t"),
			is_current = tabnr == current,
		})
	end
	return result
end

--- Snacks picker that closes selected tabs (multi-select with <Tab>).
--- Leaves the worktree on disk; use `<leader>gwd` for actual deletion.
function M.close_tabs()
	if #vim.api.nvim_list_tabpages() <= 1 then
		vim.notify("Only one tab open", vim.log.levels.INFO)
		return
	end

	local items = {}
	for _, t in ipairs(list_open_tabs()) do
		local prefix = t.is_current and "* " or "  "
		table.insert(items, {
			text = t.branch .. " " .. t.cwd,
			display = string.format("%s%2d  %-24s %s", prefix, t.tabnr, t.branch, t.basename),
			tab = t,
		})
	end

	Snacks.picker.pick({
		source = "close_tabs",
		title = "Close Tabs (<Tab>: multi-select, <CR>: close)",
		items = items,
		format = function(item)
			return { { item.display } }
		end,
		confirm = function(picker, item)
			-- `selected` honours <Tab> multi-select; falls back to the focused
			-- item when nothing is explicitly marked.
			local selected = picker:selected({ fallback = true })
			picker:close()

			-- Close from largest tabnr to smallest so earlier closes don't shift
			-- the numbers of tabs still queued.
			local tabnrs = {}
			for _, sel in ipairs(selected) do
				table.insert(tabnrs, sel.tab.tabnr)
			end
			table.sort(tabnrs, function(a, b)
				return a > b
			end)

			local closed = 0
			for _, tnr in ipairs(tabnrs) do
				if #vim.api.nvim_list_tabpages() <= 1 then
					break
				end
				if pcall(vim.cmd, tnr .. "tabclose") then
					closed = closed + 1
				end
			end
			if closed > 0 then
				vim.notify(string.format("Closed %d tab%s", closed, closed == 1 and "" or "s"))
			end
		end,
	})
end

function M.review_pr()
	input("Review PR #: ", function(pr)
		in_new_tab(function()
			vim.cmd("GitWorktreeReview " .. pr)
		end)
	end)
end

local function claude()
	return require("claude_workflow")
end

-- worktree+claude 経路で毎回 claude に渡す built-in な自走指示。
-- 「リポジトリ自体を見て起動方法を見つけ、検証して PR まで作って終わる」を
-- claude に任せる前提なので、リポジトリ側に追加ファイル (.claude-worktree.md
-- 等) を置かなくて済むよう汎用に書く。
-- vim.g.claude_worktree_prompt で完全上書き、`false` を入れると disable。
local DEFAULT_WORKFLOW_PROMPT = table.concat({
	"あなたはこの worktree タブで 1 タスクを end-to-end で完結させてください。",
	"",
	"1. 最初に必要なら package.json / Makefile / Procfile / docker-compose.yml /",
	"   README / .envrc などを見て、このリポジトリの dev サーバー起動方法と",
	"   テストコマンドを調べてください。CLAUDE.md があれば最優先で従う。",
	"2. 実装後、上で見つけた手順で dev サーバーを起動し、変更箇所が動いていることを",
	"   curl / status code / ログ出力 のいずれかで確認してください (UI なら",
	"   describe するだけでも可)。",
	"3. テストコマンドがあれば走らせて pass を確認してください。",
	'4. `git add -A && git commit -m "<concise message>"` → `git push -u origin HEAD` →',
	"   `gh pr create --fill` で PR を作成し、URL を出力してユーザに伝えてください。",
	"",
	"途中で判断に迷ったら勝手に進めず、何が分からないかをユーザに質問してください。",
}, "\n")

function M.workflow_prompt()
	local override = vim.g.claude_worktree_prompt
	if override == false then
		return nil
	end
	if type(override) == "string" and override ~= "" then
		return override
	end
	return DEFAULT_WORKFLOW_PROMPT
end

-- claude.open に渡す opts に append_system_prompt を仕込んだ table を返す。
local function with_workflow(opts)
	opts = opts or {}
	if not opts.append_system_prompt then
		opts.append_system_prompt = M.workflow_prompt()
	end
	return opts
end

function M.create_with_claude()
	input("New worktree branch (+ claude): ", function(branch)
		in_new_tab(function()
			vim.cmd("GitWorktreeCreate " .. branch)
			claude().open(with_workflow({ no_split = true }))
		end)
	end)
end

function M.create_from_default_with_claude()
	input("New worktree branch (from default + claude): ", function(branch)
		in_new_tab(function()
			vim.cmd("GitWorktreeCreate " .. branch .. " --from-default")
			claude().open(with_workflow({ no_split = true }))
		end)
	end)
end

function M.review_pr_with_claude()
	input("Review PR # (+ claude --from-pr): ", function(pr)
		in_new_tab(function()
			vim.cmd("GitWorktreeReview " .. pr)
			-- レビュー経路は "PR を作る" 目的ではないので自走 prompt は渡さない。
			-- claude --from-pr が既存セッションを拾ってくれるのでそれだけで足りる。
			claude().open({ from_pr = pr, no_split = true })
		end)
	end)
end

local function sanitize_branch(name)
	name = name:gsub("^[\"`']+", ""):gsub("[\"`']+$", "")
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
	local prompt = from_default and "Task (claude picks branch, from default): " or "Task (claude picks branch): "
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
					claude().open(with_workflow({ prompt = task, no_split = true }))
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

-- edaha 経路: ローカル ollama (qwen3.5:4b) で命名 → worktree → claude にタスク注入。
-- claude -p 課金を避けたいときの代替。本物の ollama 呼び出しはテストから差し替え
-- できるよう M._namer_edaha 経由にしておく。
local function default_namer_edaha(task)
	local ok, edaha = pcall(require, "edaha")
	if not ok then
		return nil, "edaha.nvim not installed"
	end
	return edaha.name(task)
end

M._namer_edaha = default_namer_edaha

local function create_from_task_edaha(from_default)
	local prompt = from_default and "Task (edaha picks branch, from default): " or "Task (edaha picks branch): "
	input(prompt, function(task)
		-- ollama は同期 (vim.system():wait()) なので呼び出し中は UI が止まる。
		-- 既知トレードオフ — claude -p 経路 (gwt/gwT) を使えば async。
		vim.notify("edaha: choosing a branch name…")
		local branch, err = M._namer_edaha(task)
		if not branch or branch == "" then
			vim.notify("edaha failed: " .. (err or "no name"), vim.log.levels.ERROR)
			return
		end
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
				claude().open(with_workflow({ prompt = task, no_split = true }))
			end)
		end)
	end)
end

function M.create_with_edaha_task()
	create_from_task_edaha(false)
end

function M.create_from_default_with_edaha_task()
	create_from_task_edaha(true)
end

return M
