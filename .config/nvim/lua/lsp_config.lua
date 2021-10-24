-- lspconfig
 require'lspconfig'.tsserver.setup{
   filetypes = {'typescript', 'typescript.tsx', 'typescriptreact'},
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
require'lspconfig'.gopls.setup{}

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
vim.api.nvim_set_keymap('n', 'gd', ":lua require'telescope.builtin'.lsp_definitions{}<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gD', ':lua vim.lsp.buf.declaration()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gl', ":lua require'telescope.builtin'.lsp_references{}<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gr', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ga', ":lua require'telescope.builtin'.lsp_code_actions{}<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>W', ':lua vim.lsp.buf.formatting_sync(nil, 100)<CR>', { noremap = true, silent = false })

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'single',
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
local cmp = require'cmp'
cmp.setup({
  formatting = {
    format = require('lspkind').cmp_format({
      with_text = true,
      menu = {
        nvim_lsp = '[LSP]',
        buffer = '[Buf]',
        luasnip = '[LSnip]',
        nvim_lua = '[Lua]',
      },
    }),
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  documentation = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "vsnip" },
    { name = "luasnip" },
    { name = "cmp_tabnine" },
    { name = "nvim_lua" },
    { name = "buffer" },
    { name = "calc" },
    { name = "emoji" },
    { name = "treesitter" },
    { name = "crates" },
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
})

require("nvim-autopairs.completion.cmp").setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
  auto_select = true, -- automatically select the first item
  insert = false, -- use insert confirm behavior instead of replace
  map_char = { -- modifies the function or method delimiter by filetypes
    all = '(',
    tex = '{'
  }
})
