-- LSP config (the mappings used in the default file don't quite work right)
vim.api.nvim_set_keymap('n', 'gd', ":lua require'telescope.builtin'.lsp_definitions{}<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gD', ':lua vim.lsp.buf.declaration()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gl', ":lua require'telescope.builtin'.lsp_references{}<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gr', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ga', ":lua require'telescope.builtin'.lsp_code_actions{}<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>W', ':lua vim.lsp.buf.formatting_sync(nil, 400)<CR>', { noremap = true, silent = false })

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'single',
})
