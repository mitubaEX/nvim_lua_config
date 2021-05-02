-- basic
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, silent = false }) 

-- Telescope
vim.api.nvim_set_keymap('n', '<Leader>ff', '<cmd>Telescope find_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>', { noremap = true, silent = false }) 
vim.api.nvim_set_keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = false }) 
vim.api.nvim_set_keymap('n', '<Leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = false }) 
vim.api.nvim_set_keymap('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = false }) 
