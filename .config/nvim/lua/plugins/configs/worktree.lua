local M = {}

local function input(prompt, on_confirm)
	vim.ui.input({ prompt = prompt }, function(value)
		if not value or value == "" then
			return
		end
		on_confirm(value)
	end)
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

function M.switch()
	require("telescope").extensions.git_worktree.worktrees()
end

function M.delete()
	input("Delete worktree branch: ", function(branch)
		vim.cmd("GitWorktreeDelete " .. branch)
	end)
end

function M.review_pr()
	input("Review PR #: ", function(pr)
		vim.cmd("GitWorktreeReview " .. pr)
	end)
end

local function claude()
	return require("plugins.configs.claude_term")
end

function M.create_with_claude()
	input("New worktree branch (+ claude): ", function(branch)
		vim.cmd("GitWorktreeCreate " .. branch)
		claude().open()
	end)
end

function M.create_from_default_with_claude()
	input("New worktree branch (from default + claude): ", function(branch)
		vim.cmd("GitWorktreeCreate " .. branch .. " --from-default")
		claude().open()
	end)
end

function M.review_pr_with_claude()
	input("Review PR # (+ claude --from-pr): ", function(pr)
		vim.cmd("GitWorktreeReview " .. pr)
		claude().open({ from_pr = pr })
	end)
end

return M
