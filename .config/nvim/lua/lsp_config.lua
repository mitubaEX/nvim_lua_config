-- lspconfig
require'lspconfig'.tsserver.setup{}
require'lspconfig'.solargraph.setup{}
require'lspconfig'.flow.setup{}
require'lspconfig'.yamlls.setup{}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.pyright.setup{}

-- lsp compe
vim.api.nvim_command('set completeopt=menuone,noselect')
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = true;
    spell = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
  };
}
vim.api.nvim_command('inoremap <silent><expr> <C-Space> compe#complete()')
vim.api.nvim_command('inoremap <silent><expr> <CR>      compe#confirm("<CR>")')

-- lspsaga
local saga = require 'lspsaga'
saga.init_lsp_saga()
