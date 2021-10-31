-- remove all trailing whitespace on save
vim.cmd('autocmd BufWritePre * %s/\\s\\+$//e')

-- lsp format
vim.cmd('autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 500)')

-- open spec template
vim.cmd('autocmd BufNewFile *_spec.rb 0r ~/.config/nvim/template/template_spec.rb')

-- set filetype
vim.cmd('autocmd bufnewfile,bufread *.tsx set filetype=typescriptreact')
vim.cmd('autocmd bufnewfile,bufread *.jsx set filetype=javascriptreact')
vim.cmd('autocmd bufnewfile,bufread *.js set filetype=javascriptreact')
