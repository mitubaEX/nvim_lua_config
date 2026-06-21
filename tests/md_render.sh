#!/usr/bin/env bash
# Guards md-render.nvim wiring:
#   * the <Plug>(md-render-*) keymaps in lang.lua are registered as lazy keys
#     (desc match avoids <leader> expansion fragility in maparg()).
#   * the :MdRender command becomes available after the plugin is loaded
#     via its `cmd` trigger.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. The three normal-mode keymaps registered via lazy `keys` exist.
run_nv \
  -c 'lua local want = {
        ["Markdown preview (toggle)"] = false,
        ["Markdown preview in tab (toggle)"] = false,
        ["Markdown render demo"] = false,
      }
       for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
         if m.desc and want[m.desc] == false then want[m.desc] = true end
       end
       for d, found in pairs(want) do
         if not found then print("missing keymap with desc: " .. d); vim.cmd("cquit") end
       end' \
  -c qa

# 2. Triggering the lazy load surfaces the :MdRender command.
run_nv \
  -c 'lua require("lazy").load({ plugins = { "md-render.nvim" } })
       if vim.fn.exists(":MdRender") ~= 2 then print("missing command: MdRender"); vim.cmd("cquit") end' \
  -c qa
