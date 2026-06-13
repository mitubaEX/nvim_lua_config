-- bufferline.nvim opts, extracted from plugins/ui.lua.
--
-- Tab page bar: shows Vim tabs (each tab ≈ a worktree in this config).
-- Labels render the tab's cwd basename so a worktree tab reads as the
-- branch/dir name (e.g. `add_tab_bar_plugin`) instead of the active buffer.
return {
	options = {
		mode = "tabs",
		style_preset = "default",
		-- Prefix each tab with its ordinal (1., 2., …) so it doubles as
		-- the `<n>gt` target. In tabs mode the ordinal equals the tab's
		-- position, i.e. the number Vim uses for `:tabnext`.
		numbers = "ordinal",
		diagnostics = "nvim_lsp",
		show_buffer_close_icons = false,
		show_close_icon = false,
		separator_style = "thin",
		always_show_bufferline = true,
		indicator = { style = "underline" },
		name_formatter = function(opts)
			-- Closing a tab can cause bufferline to re-render with a
			-- stale `tabnr` that no longer exists. `vim.fn.getcwd(-1, tabnr)`
			-- raises E5000 in that case, surfacing as E5108. Guard with a
			-- range check and pcall, falling back to the buffer name.
			local tabnr = opts.tabnr
			if tabnr and tabnr >= 1 and tabnr <= vim.fn.tabpagenr("$") then
				local ok, cwd = pcall(vim.fn.getcwd, -1, tabnr)
				if ok then
					local label = vim.fn.fnamemodify(cwd, ":t")
					if label ~= "" then
						local ok_notif, notif = pcall(require, "claude_workflow")
						if ok_notif and notif.pending(cwd) then
							label = "● " .. label
						end
						return label
					end
				end
			end
			return opts.name
		end,
	},
}
