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

-- Tab navigation: each tab roughly maps to a worktree in this config, so
-- `gt`/`gT` gets tedious. Override H/L (screen top/bottom) with single-stroke
-- tab cycling, and bind <Leader>1..9 / <Leader>0 to jump directly by index
-- (matches the order shown in bufferline's tab bar).
vim.keymap.set("n", "<S-l>", ":tabnext<CR>", { noremap = true, silent = true, desc = "Tab: next" })
vim.keymap.set("n", "<S-h>", ":tabprevious<CR>", { noremap = true, silent = true, desc = "Tab: previous" })
vim.keymap.set("n", "<Leader>0", ":tablast<CR>", { noremap = true, silent = true, desc = "Tab: last" })
for i = 1, 9 do
	vim.keymap.set(
		"n",
		"<Leader>" .. i,
		string.format("<Cmd>tabnext %d<CR>", i),
		{ noremap = true, silent = true, desc = "Tab: go to " .. i }
	)
end
