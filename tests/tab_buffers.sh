#!/usr/bin/env bash
# `;` lists only the current tab's buffers via our own per-tab tracking
# (plugins.configs.tab_buffers), not telescope's path-based cwd_only. Cover the
# module's isolation guarantee and guard the keymap rebind so it can't silently
# revert to the global buffer list (the old `<cmd>Telescope buffers`).
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. Module API exists.
run_nv -c 'lua local m = require("plugins.configs.tab_buffers"); if type(m.setup) ~= "function" or type(m.current_tab_bufnrs) ~= "function" then print("missing tab_buffers API"); vim.cmd("cquit") end' -c qa

# 2. Buffers are scoped per tab: a buffer opened in tab 2 must not appear in
#    tab 1, and vice versa.
run_nv -c 'lua
local tb = require("plugins.configs.tab_buffers")
tb.setup()
local function has(list, x) for _, v in ipairs(list) do if v == x then return true end end return false end

vim.cmd("edit /tmp/nvtest_tab_A")
local a = vim.api.nvim_get_current_buf()
vim.cmd("tabnew /tmp/nvtest_tab_B")
local b = vim.api.nvim_get_current_buf()

local t2 = tb.current_tab_bufnrs()
if not has(t2, b) then print("tab2 should contain B"); vim.cmd("cquit") end
if has(t2, a) then print("tab2 must NOT contain A"); vim.cmd("cquit") end

vim.cmd("tabprevious")
local t1 = tb.current_tab_bufnrs()
if not has(t1, a) then print("tab1 should contain A"); vim.cmd("cquit") end
if has(t1, b) then print("tab1 must NOT contain B"); vim.cmd("cquit") end
' -c qa

# 3. `;` is bound to a callback (the custom picker), not the old global builtin.
run_nv \
  -c 'lua local d = vim.fn.maparg(";", "n", false, true); if not (type(d) == "table" and d.callback) then print("; not mapped to a callback"); vim.cmd("cquit") end; if d.desc ~= "Buffers in current tab" then print("unexpected ; desc: " .. tostring(d.desc)); vim.cmd("cquit") end' \
  -c qa
