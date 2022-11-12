-- LSP config (the mappings used in the default file don't quite work right)
vim.keymap.set('n', 'gd', ":lua require'telescope.builtin'.lsp_definitions{}<CR>", { noremap = true, silent = true })
vim.keymap.set('n', 'gD', ':lua vim.lsp.buf.declaration()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'gl', ":lua require'telescope.builtin'.lsp_references{}<CR>", { noremap = true, silent = true })
vim.keymap.set('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'gr', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'ga', ":lua require'telescope.builtin'.lsp_code_actions{}<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<space>f', ":lua vim.lsp.buf.format { async = true }<CR>", { noremap = true, silent = true })

vim.keymap.set('n', ']d', ":lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '[d', ":lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })

-- vim.keymap.set('n', '<Leader>W', ':lua vim.lsp.buf.formatting_sync(nil, 400)<CR>', { noremap = true, silent = false })

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'single',
})

vim.keymap.set('n', '<Leader>xx', '<cmd>TroubleToggle<CR>', { noremap = true, silent = false })
