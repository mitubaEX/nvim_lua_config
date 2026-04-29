-- Leader key is set in init.lua

-- Basic key mappings
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = false, desc = "Write file" })
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true, desc = "Exit insert mode" })

-- Paste from yank register (register 0) to avoid pollution by d/c/x
vim.keymap.set("n", "<Leader>p", '"0p', { noremap = true, silent = true, desc = 'Paste from "0 (after)' })
vim.keymap.set("n", "<Leader>P", '"0P', { noremap = true, silent = true, desc = 'Paste from "0 (before)' })
vim.keymap.set("v", "<Leader>p", '"0p', { noremap = true, silent = true, desc = 'Paste from "0' })

-- Clear highlight
vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- Terminal escape
vim.keymap.set("t", "<Esc>", "<c-\\><c-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })
