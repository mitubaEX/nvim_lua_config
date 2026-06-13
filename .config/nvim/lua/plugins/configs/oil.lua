-- oil.nvim config, extracted from plugins/ui.lua.
return function()
	local oil = require("oil")

	oil.setup({
		keymaps = {
			["q"] = { "actions.close", mode = "n" },
			["<C-d>"] = "actions.preview_scroll_down",
			["<C-u>"] = "actions.preview_scroll_up",
			["<leader>ff"] = {
				function()
					Snacks.picker.files({
						cwd = require("oil").get_current_dir(),
					})
				end,
				mode = "n",
				nowait = true,
				desc = "Find files in the current directory",
			},
		},
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "OilEnter",
		callback = vim.schedule_wrap(function(args)
			if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
				oil.open_preview()
			end
		end),
	})
end
