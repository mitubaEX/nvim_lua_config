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
  },
  flags = {
    debounce_text_changes = 150,
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