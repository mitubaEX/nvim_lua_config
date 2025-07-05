-- Leader key is set in init.lua

-- Basic key mappings
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = false })
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

-- Copy from register 0
local bufopts = { noremap = true, silent = true, buffer = 0 }
vim.keymap.set("n", "<Leader>p", '"0p', bufopts)
vim.keymap.set("n", "<Leader>P", '"0P', bufopts)
vim.keymap.set("v", "<Leader>p", '"0p', bufopts)

-- Clear highlight
vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true })

-- Terminal escape
vim.keymap.set("t", "<Esc>", "<c-\\><c-n>", { noremap = true, silent = true })
