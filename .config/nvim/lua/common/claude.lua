-- Claude :terminal keymaps.
-- User commands (:Claude / :ClaudeContinue / ...) are provided by the
-- claude_workflow.nvim plugin's plugin/ file; we only wire keymaps here.

local function term()
	return require("claude_workflow")
end

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
