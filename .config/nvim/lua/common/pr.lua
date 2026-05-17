-- PR user commands + keymaps.
-- Backed by lua/plugins/configs/pr.lua (gh + claude_term integration).

local function pr()
	return require("plugins.configs.pr")
end

vim.api.nvim_create_user_command("PRCreate", function(opts)
	pr().create({ draft = opts.bang })
end, { bang = true, desc = "Create PR for current branch (! = draft)" })

vim.api.nvim_create_user_command("PRCreateReview", function(opts)
	pr().create_with_claude_review({ draft = opts.bang })
end, {
	bang = true,
	desc = "Create PR + ask cwd claude to review (! = draft)",
})

vim.api.nvim_create_user_command("PRView", function()
	pr().view()
end, { desc = "Open current branch's PR in browser" })

vim.api.nvim_create_user_command("PRStatus", function()
	pr().status()
end, { desc = "Show gh pr status" })

vim.api.nvim_create_user_command("PRReview", function()
	pr().request_review()
end, { desc = "Ask cwd claude to review the current PR" })

local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map("<leader>gpc", function()
	pr().create()
end, "PR: create")
map("<leader>gpC", function()
	pr().create_with_claude_review()
end, "PR: create + claude review")
map("<leader>gpd", function()
	pr().create({ draft = true })
end, "PR: create (draft)")
map("<leader>gpv", function()
	pr().view()
end, "PR: view in browser")
map("<leader>gps", function()
	pr().status()
end, "PR: status")
map("<leader>gpr", function()
	pr().request_review()
end, "PR: request claude review")
