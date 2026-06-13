#!/usr/bin/env bash
# Guards the editor brush-up:
#   * the snacks/treesitter/oil/bufferline configs extracted into
#     plugins/configs/ keep their expected shape (so the thin specs in
#     editor.lua/ui.lua that `require` them stay valid), and
#   * the keymaps added during the same pass stay wired:
#       <leader>gg  -> Neogit         (lazy `keys` stub)
#       -           -> Oil            (lazy `keys` stub)
#       <leader>go  -> Snacks.gitbrowse (registered at startup)
# Asserting by `desc` sidesteps <leader> expansion in maparg().
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. Extracted config modules load and have the shape the specs depend on.
run_nv \
  -c 'lua local s = require("plugins.configs.snacks")
       if type(s.opts) ~= "table" then print("snacks.opts not a table"); vim.cmd("cquit") end
       if type(s.config) ~= "function" then print("snacks.config not a function"); vim.cmd("cquit") end
       if type(require("plugins.configs.treesitter")) ~= "function" then print("treesitter config not a function"); vim.cmd("cquit") end
       if type(require("plugins.configs.oil")) ~= "function" then print("oil config not a function"); vim.cmd("cquit") end
       local bo = require("plugins.configs.bufferline")
       if type(bo) ~= "table" or bo.options == nil then print("bufferline opts missing options"); vim.cmd("cquit") end
       if bo.options.numbers ~= "ordinal" then print("bufferline numbers != ordinal"); vim.cmd("cquit") end
       if type(bo.options.name_formatter) ~= "function" then print("bufferline name_formatter not a function"); vim.cmd("cquit") end' \
  -c qa

# 2. The newly-added normal-mode keymaps are registered (matched by desc).
run_nv \
  -c 'lua local want = { ["Git: Neogit status"] = false, ["Oil: open parent dir"] = false, ["Git: open in browser"] = false }
       for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
         if m.desc and want[m.desc] == false then want[m.desc] = true end
       end
       for d, found in pairs(want) do
         if not found then print("missing keymap with desc: " .. d); vim.cmd("cquit") end
       end' \
  -c qa
