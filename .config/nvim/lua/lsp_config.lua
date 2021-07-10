-- lspconfig
 require'lspconfig'.tsserver.setup{
   -- filetypes = {'typescript', 'typescript.tsx', 'typescriptreact'}
   settings = {documentFormatting = false}
 }
require'lspconfig'.solargraph.setup{
  init_options = {codeAction = false},
  filetypes = {"ruby", "rakefile", "rspec"},
  settings = {
      solargraph = {
          completion = true,
          diagnostic = false,
          folding = true,
          references = true,
          rename = true,
          symbols = true
      }
  }
}
require'lspconfig'.flow.setup{}
require'lspconfig'.yamlls.setup{}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.pyright.setup{}

-- efm
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  formatCommand = "eslint_d --fix ${INPUT}",
  formatStdin = true
}

local rubocop = {
  formatCommand = "rubocop -a ${INPUT}",
  formatStdin = true
}

require "lspconfig".efm.setup {
  init_options = {documentFormatting = true, codeAction = false},
  filetypes = {"javascriptreact", "javascript", "typescript", "typescriptreact", "ruby", "rspec"},
  settings = {
    rootMarkers = {".git/"},
    languages = {
      javascript = {
        eslint
      },
      javascriptreact = {
        eslint
      },
      typescript = {
        eslint
      },
      typescriptreact = {
        eslint
      },
      ruby = {
        rubocop
      },
      rspec = {
        rubocop
      }
    }
  }
}

-- lua
local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end

-- get home directory
local handle = io.popen('echo $HOME')
local home_path = handle:read("*a")
handle:close()

-- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
local sumneko_root_path = home_path:sub(0, -2) .. '/.ghq/src/github.com/sumneko/lua-language-server'
local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

-- lua-dev.nvim
local luadev = require("lua-dev").setup({
  lspconfig = {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"}
  },
})

require'lspconfig'.sumneko_lua.setup(luadev)

-- LSP config (the mappings used in the default file don't quite work right)
vim.api.nvim_set_keymap('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gD', ':lua vim.lsp.buf.declaration()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gl', ':lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })

-- commented options are defaults
require('lspkind').init({
    with_text = true,
    symbol_map = {
      Text = '',
      Method = 'ƒ',
      Function = '',
      Constructor = '',
      Variable = '',
      Class = '',
      Interface = 'ﰮ',
      Module = '',
      Property = '',
      Unit = '',
      Value = '',
      Enum = '了',
      Keyword = '',
      Snippet = '﬌',
      Color = '',
      File = '',
      Folder = '',
      EnumMember = '',
      Constant = '',
      Struct = ''
    },
})

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
vim.api.nvim_command([[
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  inoremap <silent><expr> <C-Space> compe#complete()
  inoremap <silent><expr> <CR>      compe#confirm("<CR>")
]])

-- lspsaga
local saga = require 'lspsaga'
saga.init_lsp_saga()

vim.api.nvim_set_keymap('n', 'ga', ':Lspsaga code_action<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'ga', ':Lspsaga range_code_action<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'K', ':Lspsaga hover_doc<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'gr', ':Lspsaga rename<CR>', { noremap = true, silent = true })
