require'nvim-tree'.setup {
  renderer = {
    highlight_git = true,
  }
}
vim.keymap.set('n', '<Leader>d', '<cmd>NvimTreeFindFile<CR>', { noremap = true, silent = false })
