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
  },
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
local luadev = require("lua-dev").setup({
  lspconfig = {
    -- cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    capabilities = capabilities
  },
})

require'lspconfig'.sumneko_lua.setup(luadev)

-- null-ls
require("null-ls").setup({
  sources = {
    require("null-ls").builtins.diagnostics.eslint,
    require("null-ls").builtins.formatting.eslint,
  },
})
