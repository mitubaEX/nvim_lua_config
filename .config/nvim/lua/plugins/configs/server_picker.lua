-- Snacks-based pickers for mitubaEX/server.nvim.
--
-- server.nvim ships its own telescope extension (lua/telescope/_extensions/
-- server.lua), but its state lives in plain modules (server.config /
-- server.servers), so these pickers drive that API directly and need no
-- telescope. Requiring those modules lazy-loads server.nvim (running its
-- `config`/setup) on first use, so the configured servers are populated by the
-- time a picker opens. Snacks is `lazy = false`, so `Snacks.picker.*` is always
-- available here.
local M = {}

local function config()
	return require("server.config")
end

local function servers()
	return require("server.servers")
end

-- Build the server-list items. Recomputed on every call so a picker can refresh
-- its [RUNNING]/[STOPPED] column after a start/stop/restart by re-running this
-- as its `finder`.
local function server_items()
	local items = {}
	for _, name in ipairs(config().get_server_names()) do
		local cfg = config().get_server(name)
		local is_running = servers().running_servers[name] ~= nil
		local status = is_running and "[RUNNING]" or "[STOPPED]"
		local port = cfg.port and (" :" .. cfg.port) or ""
		local command_short = cfg.command:match("^([^%s]+)") or cfg.command
		table.insert(items, {
			text = name,
			display = status .. " " .. name .. port .. " (" .. command_short .. ")",
			name = name,
			is_running = is_running,
		})
	end
	return items
end

-- Picker over every configured server. <CR> toggles start/stop; the extra keys
-- mirror the old telescope extension (logs / restart / stop / start).
function M.servers()
	if #config().get_server_names() == 0 then
		vim.notify("No servers configured", vim.log.levels.WARN)
		return
	end

	Snacks.picker.pick({
		source = "servers",
		title = "Server Manager",
		finder = server_items,
		format = function(item)
			return { { item.display } }
		end,
		confirm = function(picker, item)
			if not item then
				return
			end
			if item.is_running then
				servers().stop(item.name)
			else
				servers().start(item.name)
			end
			picker:find() -- refresh the status column in place
		end,
		actions = {
			server_logs = function(picker, item)
				if item then
					picker:close()
					M.logs({ server_name = item.name })
				end
			end,
			server_restart = function(picker, item)
				if item then
					servers().restart(item.name)
					picker:find()
				end
			end,
			server_stop = function(picker, item)
				if item and item.is_running then
					servers().stop(item.name)
					picker:find()
				end
			end,
			server_start = function(picker, item)
				if item and not item.is_running then
					servers().start(item.name)
					picker:find()
				end
			end,
		},
		win = {
			input = {
				keys = {
					["<C-l>"] = { "server_logs", mode = { "i", "n" } },
					["<C-r>"] = { "server_restart", mode = { "i", "n" } },
					["<C-x>"] = { "server_stop", mode = { "i", "n" } },
					["<C-o>"] = { "server_start", mode = { "i", "n" } },
				},
			},
		},
	})
end

-- Logs picker. With no `opts.server_name` it first asks which running server to
-- inspect, then re-enters with that name. <C-y> yanks the focused log line.
function M.logs(opts)
	opts = opts or {}
	local server_name = opts.server_name

	if not server_name then
		local running = {}
		for name in pairs(servers().running_servers) do
			table.insert(running, { text = name, name = name })
		end
		if #running == 0 then
			vim.notify("No running servers to show logs for", vim.log.levels.WARN)
			return
		end
		Snacks.picker.pick({
			source = "server_logs_select",
			title = "Select Server for Logs",
			items = running,
			format = function(item)
				return { { item.name } }
			end,
			confirm = function(picker, item)
				picker:close()
				if item then
					M.logs({ server_name = item.name })
				end
			end,
		})
		return
	end

	local logs = servers().get_logs(server_name)
	if #logs == 0 then
		vim.notify("No logs available for server '" .. server_name .. "'", vim.log.levels.WARN)
		return
	end

	local items = {}
	for _, log in ipairs(logs) do
		local timestamp = os.date("%H:%M:%S", log.timestamp)
		local prefix = "[" .. timestamp .. "] " .. log.stream .. ": "
		table.insert(items, {
			text = prefix .. log.content,
			display = prefix .. log.content,
			content = log.content,
		})
	end

	Snacks.picker.pick({
		source = "server_logs",
		title = "Logs - " .. server_name,
		items = items,
		format = function(item)
			return { { item.display } }
		end,
		confirm = function(picker)
			picker:close() -- logs are read-only; <CR> just closes
		end,
		actions = {
			copy_log = function(_, item)
				if item then
					vim.fn.setreg("+", item.content)
					vim.notify("Log line copied to clipboard", vim.log.levels.INFO)
				end
			end,
		},
		win = {
			input = {
				keys = {
					["<C-y>"] = { "copy_log", mode = { "i", "n" } },
				},
			},
		},
	})
end

return M
