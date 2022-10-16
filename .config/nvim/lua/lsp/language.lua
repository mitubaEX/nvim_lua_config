-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require'lspconfig'

-- lspconfig
lspconfig.tsserver.setup{
  filetypes = {'typescript', 'typescript.tsx', 'typescriptreact'},
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
  settings = {documentFormatting = false},
  capabilities = capabilities
}
lspconfig.solargraph.setup{
  cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
  filetypes = {"ruby", "rakefile", "rspec"},
  capabilities = capabilities
}
lspconfig.flow.setup{
  capabilities = capabilities
}
lspconfig.yamlls.setup{
  capabilities = capabilities
}
lspconfig.rust_analyzer.setup{
  capabilities = capabilities
}
lspconfig.pyright.setup{
  capabilities = capabilities
}
lspconfig.gopls.setup{
  capabilities = capabilities
}
require "lsp_signature".setup({
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
})
lspconfig.denols.setup{
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")
}

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

lspconfig.sumneko_lua.setup {
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

-- lspconfig.eslint.setup{}

-- null-ls
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with {
      cwd = function()
        return vim.fn.getcwd()
      end,
      prefer_local = "node_modules/.bin",
    },
    null_ls.builtins.diagnostics.eslint_d.with {
      cwd = function()
        return vim.fn.getcwd()
      end,
      -- command = "node_modules/.bin/eslint",
    },
  },
})
