-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- lspconfig
require'lspconfig'.tsserver.setup{
  filetypes = {'typescript', 'typescript.tsx', 'typescriptreact'},
  settings = {documentFormatting = false},
  capabilities = capabilities
}
require'lspconfig'.solargraph.setup{
  cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
  filetypes = {"ruby", "rakefile", "rspec"},
  capabilities = capabilities
}
require'lspconfig'.flow.setup{
  capabilities = capabilities
}
require'lspconfig'.yamlls.setup{
  capabilities = capabilities
}
require'lspconfig'.rust_analyzer.setup{
  capabilities = capabilities
}
require'lspconfig'.pyright.setup{
  capabilities = capabilities
}
require'lspconfig'.gopls.setup{
  capabilities = capabilities
}
require "lsp_signature".setup({
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
})

-- lua-dev.nvim
-- local luadev = require("lua-dev").setup({
--   lspconfig = {
--     -- cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
--     capabilities = capabilities
--   },
-- })
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

require'lspconfig'.sumneko_lua.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = { enable = false, },
    },
  },
}

-- require'lspconfig'.eslint.setup{}

-- null-ls
null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with {
      prefer_local = "/home/nakamura-jun/CFO-Alpha/node_modules/.bin",
    },
  },
})
