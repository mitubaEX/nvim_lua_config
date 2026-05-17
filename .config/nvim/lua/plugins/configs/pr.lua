-- GitHub PR helpers backed by `gh` CLI.
-- 担う範囲: worktree で作業 → push → `gh pr create` → そのまま cwd の
-- claude terminal に「レビューして」prompt を送る、までの一連の流れ。
-- ロジックは vim.system による async 呼び出しに揃え、結果は vim.notify。

local M = {}

local function notify(msg, level)
	vim.notify("[PR] " .. (msg or ""), level or vim.log.levels.INFO)
end

local function current_branch()
	local out = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")
	if vim.v.shell_error ~= 0 or not out[1] or out[1] == "HEAD" or out[1] == "" then
		return nil
	end
	return out[1]
end

local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

--- Look up the PR (if any) for the current branch.
--- Returns { number, url, state, isDraft } or nil.
function M.current_pr()
	if vim.fn.executable("gh") ~= 1 then
		return nil
	end
	local out = vim.fn.systemlist({
		"gh",
		"pr",
		"view",
		"--json",
		"number,url,state,isDraft",
	})
	if vim.v.shell_error ~= 0 then
		return nil
	end
	local ok, decoded = pcall(vim.json.decode, table.concat(out, "\n"))
	if not ok or type(decoded) ~= "table" or not decoded.number then
		return nil
	end
	return decoded
end

local function ensure_gh()
	if vim.fn.executable("gh") ~= 1 then
		notify("gh CLI not found", vim.log.levels.ERROR)
		return false
	end
	return true
end

--- Push current branch to origin, then `gh pr create`.
--- @param opts table|nil { draft = bool, web = bool, on_success = function({url,number}) }
function M.create(opts)
	opts = opts or {}
	if not ensure_gh() then
		return
	end
	local branch = current_branch()
	if not branch then
		notify("Not on a branch (detached HEAD?)", vim.log.levels.ERROR)
		return
	end

	-- 既に PR があるならそれを返して終わる（重複作成は gh が弾くが、こちらで
	-- 先に検知すると on_success に既存 PR を流せて claude レビュー経路が活きる）。
	local existing = M.current_pr()
	if existing and existing.state == "OPEN" then
		notify(string.format("PR #%d already exists: %s", existing.number, existing.url or ""))
		if opts.on_success then
			opts.on_success({ url = existing.url, number = existing.number })
		end
		return
	end

	notify("Pushing " .. branch .. " to origin...")
	vim.system(
		{ "git", "push", "-u", "origin", "HEAD" },
		{ text = true },
		vim.schedule_wrap(function(push_out)
			if push_out.code ~= 0 then
				notify("git push failed: " .. trim(push_out.stderr), vim.log.levels.ERROR)
				return
			end

			local args = { "gh", "pr", "create", "--fill" }
			if opts.draft then
				table.insert(args, "--draft")
			end
			if opts.web then
				table.insert(args, "--web")
			end

			notify("Creating PR (" .. table.concat(args, " ") .. ")...")
			vim.system(
				args,
				{ text = true },
				vim.schedule_wrap(function(out)
					if out.code ~= 0 then
						notify("gh pr create failed: " .. trim(out.stderr), vim.log.levels.ERROR)
						return
					end
					local url = (out.stdout or ""):match("https?://%S+")
					local number_str = url and url:match("/(%d+)$") or nil
					local number = number_str and tonumber(number_str) or nil
					if url then
						notify("PR created: " .. url .. " (URL copied to + register)")
						pcall(vim.fn.setreg, "+", url)
					else
						notify("PR created (no URL parsed from output)")
					end
					if opts.on_success then
						opts.on_success({ url = url, number = number })
					end
				end)
			)
		end)
	)
end

--- Open the PR for the current branch in the browser.
function M.view()
	if not ensure_gh() then
		return
	end
	vim.system(
		{ "gh", "pr", "view", "--web" },
		{ text = true },
		vim.schedule_wrap(function(out)
			if out.code ~= 0 then
				notify("gh pr view failed: " .. trim(out.stderr), vim.log.levels.ERROR)
			end
		end)
	)
end

--- Show PR status (gh pr status) in a notify popup.
function M.status()
	if not ensure_gh() then
		return
	end
	vim.system(
		{ "gh", "pr", "status" },
		{ text = true },
		vim.schedule_wrap(function(out)
			if out.code ~= 0 then
				notify("gh pr status failed: " .. trim(out.stderr), vim.log.levels.ERROR)
				return
			end
			notify(trim(out.stdout))
		end)
	)
end

--- Compose the review prompt for a PR number.
--- Exposed for tests.
function M.review_prompt(pr_number)
	return string.format(
		"PR #%s を作成しました。`gh pr diff %s` で差分を確認し、"
			.. "ロジックバグ・規約違反・テスト漏れ・命名のおかしさを具体的に指摘してください。"
			.. "問題がなければ「LGTM」と返してください。",
		tostring(pr_number),
		tostring(pr_number)
	)
end

--- Send a review request to the cwd's claude terminal.
--- pr_number nil なら gh から自動取得。
function M.request_review(pr_number)
	if not pr_number then
		local pr = M.current_pr()
		if not pr or not pr.number then
			notify("No PR found for current branch (run :PRCreate first)", vim.log.levels.ERROR)
			return
		end
		pr_number = pr.number
	end
	require("plugins.configs.claude_term").send(M.review_prompt(pr_number))
end

--- Create PR, then immediately ask claude (in the same cwd) to review it.
--- これが「問題なければPR作成、レビューまで依頼する」の一筆書きフロー。
function M.create_with_claude_review(opts)
	opts = vim.tbl_extend("force", opts or {}, {
		on_success = function(result)
			if result and result.number then
				M.request_review(result.number)
			else
				notify("PR created but no number parsed; skip claude review", vim.log.levels.WARN)
			end
		end,
	})
	M.create(opts)
end

return M
