local opts = { noremap = true, silent = true }
local ai_terminal = require("common.ai_terminal")

vim.keymap.set("n", "<Leader>w", "<cmd>w<CR>", { desc = "Write file" })
vim.keymap.set("n", "<Leader>q", "<cmd>q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<Leader>Q", "<cmd>qa!<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<Leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<Leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.bo[buf].buflisted then
			pcall(vim.api.nvim_buf_delete, buf, { force = false })
		end
	end
end, { desc = "Delete other buffers" })
vim.keymap.set("n", "<Leader>e", "<cmd>Oil<CR>", { desc = "Open file explorer" })

vim.keymap.set("i", "jj", "<ESC>", opts)

vim.keymap.set("n", "<Leader>p", '"0p', opts)
vim.keymap.set("n", "<Leader>P", '"0P', opts)
vim.keymap.set("v", "<Leader>p", '"0p', opts)

vim.keymap.set("n", "<Esc><Esc>", "<cmd>noh<CR>", { desc = "Clear highlight" })
vim.keymap.set("n", "<Leader>,", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<Leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search open buffer" })
vim.keymap.set("n", "<Leader>:", "<cmd>Telescope command_history<CR>", { desc = "Command history" })
vim.keymap.set("n", "<Leader>.", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Quickfix prev" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Quickfix next" })
vim.keymap.set("n", "<Leader>xl", "<cmd>lopen<CR>", { desc = "Location list" })
vim.keymap.set("n", "<Leader>xq", "<cmd>copen<CR>", { desc = "Quickfix list" })

vim.keymap.set("n", "<Leader>aa", ai_terminal.open_agent, { desc = "Open AI agent terminal" })
vim.keymap.set("n", "<Leader>ar", ai_terminal.resume_agent, { desc = "Resume AI agent terminal" })
vim.keymap.set("n", "<Leader>at", ai_terminal.open_shell, { desc = "Open project terminal" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", opts)
vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", opts)
vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", opts)
vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", opts)
