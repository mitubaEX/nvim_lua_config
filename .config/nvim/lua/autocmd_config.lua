-- remove all trailing whitespace on save
vim.cmd('autocmd BufWritePre * %s/\\s\\+$//e')

-- format
vim.cmd('autocmd BufWritePost *.js,*.go FormatWrite')

-- open spec template
vim.cmd('autocmd BufNewFile *_spec.rb 0r ~/.config/nvim/template/template_spec.rb')

-- set filetype
vim.cmd('autocmd bufnewfile,bufread *.tsx set filetype=typescriptreact')
vim.cmd('autocmd bufnewfile,bufread *.jsx set filetype=javascriptreact')
vim.cmd('autocmd bufnewfile,bufread *.js set filetype=javascriptreact')

vim.cmd('au BufNewFile,BufRead *.eco setf mason')

vim.cmd('au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}')
