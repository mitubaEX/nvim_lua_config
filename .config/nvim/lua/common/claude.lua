-- Claude :terminal commands + keymaps.
-- Backed by lua/plugins/configs/claude_term.lua (per-cwd session manager).

local function term()
	return require("plugins.configs.claude_term")
end

vim.api.nvim_create_user_command("Claude", function(opts)
	term().open({ prompt = opts.args ~= "" and opts.args or nil })
end, {
	nargs = "?",
	desc = "Open claude in a :terminal split (optional initial prompt)",
})

vim.api.nvim_create_user_command("ClaudeContinue", function()
	term().open({ continue = true })
end, { desc = "Open claude with -c (continue last session in cwd)" })

vim.api.nvim_create_user_command("ClaudeResume", function(opts)
	term().open({ resume = opts.args ~= "" and opts.args or true })
end, {
	nargs = "?",
	desc = "Open claude with -r (interactive picker if no session id given)",
})

vim.api.nvim_create_user_command("ClaudeFromPR", function(opts)
	if opts.args == "" then
		vim.api.nvim_err_writeln("PR number required")
		return
	end
	term().open({ from_pr = opts.args })
end, {
	nargs = 1,
	desc = "Open claude with --from-pr <num>",
})

vim.api.nvim_create_user_command("ClaudeToggle", function()
	term().toggle()
end, { desc = "Toggle the claude terminal for the current cwd" })

vim.api.nvim_create_user_command("ClaudeKill", function()
	term().kill()
end, { desc = "Kill the claude terminal for the current cwd" })

vim.api.nvim_create_user_command("ClaudeSend", function(opts)
	term().send(opts.args)
end, {
	nargs = "+",
	desc = "Send text to the cwd's claude terminal (open if missing)",
})

local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map("<leader>cc", function()
	term().toggle()
end, "Claude: toggle terminal")
map("<leader>co", function()
	term().open()
end, "Claude: open (fresh)")
map("<leader>cC", function()
	term().open({ continue = true })
end, "Claude: continue (-c)")
map("<leader>cr", function()
	term().open({ resume = true })
end, "Claude: resume picker (-r)")
map("<leader>cx", function()
	term().kill()
end, "Claude: kill terminal")

-- Visual: send the selection to claude
vim.keymap.set("v", "<leader>cs", function()
	-- Yank visual selection to a temp register and send it.
	local saved = vim.fn.getreg("z")
	vim.cmd('noautocmd normal! "zy')
	local text = vim.fn.getreg("z")
	vim.fn.setreg("z", saved)
	term().send(text)
end, { noremap = true, silent = true, desc = "Claude: send visual selection" })
