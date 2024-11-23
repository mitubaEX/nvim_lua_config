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
