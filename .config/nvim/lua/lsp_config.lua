require('lsp.language')
require('lsp.keymap')
require('lsp.cmp')

-- vsnip
-- Expand
vim.api.nvim_command([[
imap <expr> <C-f>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-f>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'
]])
-- Jump forward or backward
vim.api.nvim_command([[
imap <expr> <C-b>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-b>'
smap <expr> <C-b>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-b>'
]])
-- If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
vim.api.nvim_command([[
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']
]])
