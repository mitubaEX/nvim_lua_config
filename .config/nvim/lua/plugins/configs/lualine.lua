return function()
	require("lualine").setup({
		sections = {
			lualine_a = {},
			lualine_b = { { "branch", icon = "" } },
			lualine_c = {
				{ "filename", file_status = true, path = 1, separator = "" },
				{ "diff" },
				{
					-- Lsp server name .
					-- ref: https://gist.github.com/shadmansaleh/cd526bc166237a5cbd51429cc1f6291b
					function()
						local msg = "No Active Lsp"
						local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
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
				{
					function()
						return require("possession.session").get_session_name() or ""
					end,
				},
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
