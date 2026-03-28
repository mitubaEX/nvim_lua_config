local M = {}

local state = {
	agent_bufnr = nil,
}

local root_markers = {
	".git",
	"package.json",
	"tsconfig.json",
	"deno.json",
	"deno.jsonc",
	"go.mod",
	"Cargo.toml",
	"pyproject.toml",
	"Gemfile",
	"Makefile",
}

local function get_root()
	local buf = vim.api.nvim_buf_get_name(0)
	local start = buf ~= "" and vim.fs.dirname(buf) or vim.uv.cwd()
	return vim.fs.root(start, root_markers) or vim.uv.cwd()
end

local function get_agent_command()
	return vim.g.ai_agent_command or vim.env.AI_AGENT_CMD or "codex"
end

local function ensure_executable(command)
	local executable = vim.split(command, "%s+")[1]
	if vim.fn.executable(executable) == 0 then
		vim.notify(("AI agent command not found: %s"):format(command), vim.log.levels.WARN)
		return false
	end

	return true
end

function M.open_agent()
	local command = get_agent_command()
	if not ensure_executable(command) then
		return
	end

	local cwd = get_root()
	vim.cmd("botright vsplit")
	vim.cmd("vertical resize 72")
	vim.cmd(("lcd %s"):format(vim.fn.fnameescape(cwd)))
	vim.cmd.terminal(command)
	state.agent_bufnr = vim.api.nvim_get_current_buf()
	vim.cmd.startinsert()
end

function M.open_shell()
	local cwd = get_root()
	vim.cmd("botright 12split")
	vim.cmd(("lcd %s"):format(vim.fn.fnameescape(cwd)))
	vim.cmd.terminal(vim.o.shell)
	vim.cmd.startinsert()
end

function M.resume_agent()
	if state.agent_bufnr and vim.api.nvim_buf_is_valid(state.agent_bufnr) then
		local windows = vim.fn.win_findbuf(state.agent_bufnr)
		if #windows > 0 then
			vim.api.nvim_set_current_win(windows[1])
			vim.cmd.startinsert()
			return
		end

		vim.cmd("botright vsplit")
		vim.cmd("vertical resize 72")
		vim.api.nvim_set_current_buf(state.agent_bufnr)
		vim.cmd.startinsert()
		return
	end

	M.open_agent()
end

return M
