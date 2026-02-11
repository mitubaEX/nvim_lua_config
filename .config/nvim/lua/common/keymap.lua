-- Leader key is set in init.lua

-- Basic key mappings
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = false })
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

-- Paste from yank register (register 0) to avoid pollution by d/c/x
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<Leader>p", '"0p', opts)
vim.keymap.set("n", "<Leader>P", '"0P', opts)
vim.keymap.set("v", "<Leader>p", '"0p', opts)

-- Clear highlight
vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true })

-- Terminal escape
vim.keymap.set("t", "<Esc>", "<c-\\><c-n>", { noremap = true, silent = true })
