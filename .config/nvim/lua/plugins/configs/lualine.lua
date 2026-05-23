-- cwd-based branch resolver. The default lualine `branch` component walks
-- upward from the current buffer's filename, which fails on unnamed buffers
-- inside a worktree (e.g. fresh `<leader>gwa` tab) because the search escapes
-- the worktree and finds the main repo's `.git` instead.
local sep = "/"

local function find_git_dir_for(dir)
	while dir and dir ~= "" and dir ~= "/" do
		local git_path = dir .. sep .. ".git"
		local stat = (vim.uv or vim.loop).fs_stat(git_path)
		if stat then
			if stat.type == "directory" then
				return git_path
			elseif stat.type == "file" then
				local f = io.open(git_path)
				if f then
					local line = f:read("*l")
					f:close()
					if line then
						local gd = line:match("^gitdir:%s*(.+)$")
						if gd then
							if gd:sub(1, 1) ~= sep then
								gd = dir .. sep .. gd
							end
							return gd
						end
					end
				end
			end
		end
		local parent = dir:match("^(.*)/[^/]+$")
		if not parent or parent == dir then
			return nil
		end
		dir = parent
	end
end

local function read_branch(git_dir)
	if not git_dir then
		return ""
	end
	local f = io.open(git_dir .. "/HEAD")
	if not f then
		return ""
	end
	local head = f:read("*l")
	f:close()
	if not head then
		return ""
	end
	local b = head:match("^ref: refs/heads/(.+)$")
	if b then
		return b
	end
	return head:sub(1, 7)
end

local cache = { cwd = nil, branch = "" }

local function worktree_branch()
	local cwd = vim.fn.getcwd()
	if cwd ~= cache.cwd then
		cache.cwd = cwd
		cache.branch = read_branch(find_git_dir_for(cwd))
	end
	return cache.branch
end

vim.api.nvim_create_autocmd({ "DirChanged", "TabEnter", "FocusGained", "ShellCmdPost" }, {
	callback = function()
		cache.cwd = nil
	end,
})

return function()
	require("lualine").setup({
		sections = {
			lualine_a = {},
			lualine_b = { { worktree_branch, icon = "" } },
			lualine_c = {
				{ "filename", file_status = true, path = 1, separator = "" },
				{ "diff" },
				{
					-- Lsp server name .
					-- ref: https://gist.github.com/shadmansaleh/cd526bc166237a5cbd51429cc1f6291b
					function()
						local msg = "No Active Lsp"
						local buf_ft = vim.bo.filetype
						local clients = vim.lsp.get_clients()
						if next(clients) == nil then
							return msg
						end

						local client_table = {}
						for _, client in ipairs(clients) do
							local filetypes = client.config.filetypes
							if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
								table.insert(client_table, client.name)
							end
						end

						if #client_table > 0 then
							return "[" .. table.concat(client_table, ",") .. "]"
						end

						return msg
					end,
					color = { fg = "#a69ded" },
					separator = "",
				},
				{ "diagnostics", sources = { "nvim_diagnostic" } },
			},
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = {},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
	})
end
