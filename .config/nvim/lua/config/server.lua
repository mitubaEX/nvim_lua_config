-- Server :terminal commands + keymaps.
-- Backed by lua/plugins/configs/server_term.lua (per-cwd session manager).

local function term()
	return require("plugins.configs.server_term")
end

local function prompt_then(action)
	vim.ui.input({ prompt = "Server cmd: ", default = term().last_cmd() or "" }, function(value)
		if not value or value == "" then
			return
		end
		action(value)
	end)
end

vim.api.nvim_create_user_command("ServerStart", function(opts)
	if opts.args ~= "" then
		term().start(opts.args)
		return
	end
	if term().resolve_cmd(nil) then
		term().start()
		return
	end
	prompt_then(term().start)
end, {
	nargs = "*",
	complete = "shellcmd",
	desc = "Start a server :terminal for the cwd (uses last cmd / g:worktree_server_cmd)",
})

vim.api.nvim_create_user_command("ServerStop", function()
	term().stop()
end, { desc = "Stop the cwd's server terminal" })

vim.api.nvim_create_user_command("ServerRestart", function(opts)
	term().restart(opts.args ~= "" and opts.args or nil)
end, {
	nargs = "*",
	complete = "shellcmd",
	desc = "Restart the cwd's server (optionally with a new cmd)",
})

vim.api.nvim_create_user_command("ServerToggle", function()
	term().toggle()
end, { desc = "Toggle the cwd's server terminal" })

local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map("<leader>ss", function()
	if term().resolve_cmd(nil) then
		term().start()
	else
		prompt_then(term().start)
	end
end, "Server: start (prompt if unknown)")
map("<leader>sS", function()
	prompt_then(term().start)
end, "Server: start with a new cmd")
map("<leader>st", function()
	term().toggle()
end, "Server: toggle terminal")
map("<leader>sx", function()
	term().stop()
end, "Server: stop")
map("<leader>sr", function()
	term().restart()
end, "Server: restart")
