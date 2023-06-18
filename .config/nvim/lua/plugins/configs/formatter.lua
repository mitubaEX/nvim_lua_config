return function()
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
            exe = "gofmt",
            args = {},
            stdin = true,
          }
        end
      },
      ruby = {
        -- syntax_tree
        function()
          return {
            exe = "bundle exec stree",
            args = {"write"},
            stdin = true,
          }
        end
      }
    }
  })
end
