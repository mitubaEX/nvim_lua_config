#!/usr/bin/env bash
# The tab page bar prefixes each tab with its ordinal number (issue #42).
# bufferline renders this from `options.numbers = "ordinal"`; in tabs mode the
# ordinal equals the tab position (the `<n>gt` target). Guard both the resolved
# option and the rendered tabline so a future opts edit can't silently drop it.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. Resolved bufferline config keeps numbers = "ordinal".
run_nv \
  -c 'lua require("lazy").load({ plugins = { "bufferline.nvim" } })' \
  -c 'lua local n = require("bufferline.config").options.numbers; if n ~= "ordinal" then print("bufferline numbers is " .. tostring(n) .. ", expected ordinal"); vim.cmd("cquit") end' \
  -c qa

# 2. The rendered tabline actually shows ordinals for each open tab.
run_nv \
  -c 'lua vim.cmd("edit /tmp/nvim_tab_a"); vim.cmd("tabnew /tmp/nvim_tab_b"); vim.cmd("tabnew /tmp/nvim_tab_c")' \
  -c 'lua require("lazy").load({ plugins = { "bufferline.nvim" } })' \
  -c 'lua vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })' \
  -c 'lua vim.schedule(function()
        local rendered = vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true }).str
        for _, n in ipairs({ "1.", "2.", "3." }) do
          if not rendered:find(n, 1, true) then
            print("tabline missing ordinal " .. n .. ", got: " .. rendered)
            vim.cmd("cquit")
          end
        end
        vim.cmd("qa")
      end)'
