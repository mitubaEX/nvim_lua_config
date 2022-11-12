local util = require("formatter.util")
require('formatter').setup({
  filetype = {
    javascript = {
      function()
        return {
          exe = "prettierd",
          args = {util.escape_path(util.get_current_buffer_file_path())},
          stdin = true
        }
      end
    },
    go = {
      -- go fmt
      function()
        return {
          exe = "gofmt", -- might prepend `bundle exec `
          args = {},
          stdin = true,
        }
      end
    }
  }
})
