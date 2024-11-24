-- set leader
vim.keymap.set("n", "<Space>", "<NOP>", { noremap = true, silent = true })
vim.g.mapleader = " "

-- basic
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = false })
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

-- copy 0 register
vim.keymap.set("n", "<Leader>p", '"0p', { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>P", '"0P', { noremap = true, silent = true })
vim.keymap.set("v", "<Leader>p", '"0p', { noremap = true, silent = true })

-- noh
vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true })

-- terminal
vim.keymap.set("t", "<Esc><Esc>", "<c-\\><c-n>", { noremap = true, silent = true })
