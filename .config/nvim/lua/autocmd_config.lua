-- remove all trailing whitespace on save
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = "*",
  command = "%s/\\s\\+$//e"
})

-- format
vim.api.nvim_create_autocmd({"BufWritePost"}, {
  pattern = {"*.js","*.go"},
  command = "FormatWrite"
})

vim.cmd([[autocmd! FileType qf nnoremap <buffer> <leader><Enter> <C-w><Enter><C-w>L]])

-- open spec template
vim.api.nvim_create_autocmd({"BufNewFile"}, {
  pattern = {"*_spec.rb"},
  command = "0r ~/.config/nvim/template/template_spec.rb"
})

vim.api.nvim_create_autocmd({"BufWritePre","BufRead"}, {
  pattern = {"*.tsx"},
  command = "set filetype=typescriptreact"
})
vim.api.nvim_create_autocmd({"BufWritePre","BufRead"}, {
  pattern = {"*.tsx","*.jsx","*.js"},
  command = "set filetype=javascriptreact"
})

vim.api.nvim_create_autocmd({"BufNewFile","BufRead"}, {
  pattern = {"*.eco"},
  command = "setf mason"
})

vim.api.nvim_create_autocmd({"TextYankPost"}, {
  pattern = {"*"},
  command = "silent! lua vim.highlight.on_yank{higroup='IncSearch', timeout=700}"
})
