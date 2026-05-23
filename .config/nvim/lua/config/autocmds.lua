-- remove all trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = "*",
	command = "%s/\\s\\+$//e",
})

-- yank highlight
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	command = "silent! lua vim.highlight.on_yank{higroup='IncSearch', timeout=700}",
})

-- restore cursor shape
-- https://vi.stackexchange.com/questions/25103/neovim-does-not-restore-terminal-cursor-on-exit
vim.api.nvim_create_autocmd({ "VimLeave" }, {
	pattern = { "*" },
	command = "silent! lua vim.opt.guicursor = 'a:hor20'",
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- join wrapped lines when yanking from terminal buffer (preserve empty lines as line breaks)
-- vim.api.nvim_create_autocmd("TermOpen", {
-- 	pattern = "*",
-- 	callback = function()
-- 		vim.keymap.set("x", "y", function()
-- 			local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."))
-- 			local result = {}
-- 			local current = {}
-- 			for _, line in ipairs(lines) do
-- 				if line == "" then
-- 					if #current > 0 then
-- 						table.insert(result, table.concat(current, ""))
-- 						current = {}
-- 					end
-- 					table.insert(result, "")
-- 				else
-- 					table.insert(current, line)
-- 				end
-- 			end
-- 			if #current > 0 then
-- 				table.insert(result, table.concat(current, ""))
-- 			end
-- 			vim.fn.setreg("+", table.concat(result, "\n"))
-- 			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
-- 		end, { buffer = true })
-- 	end,
-- })
