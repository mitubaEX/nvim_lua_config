#!/usr/bin/env bash
# Worktree switch / close-tabs pickers run on Snacks now (no telescope). Cover
# the module API, the close_tabs single-tab degrade path, and the lazy keymaps
# (<leader>gws / <leader>gwq) so the Snacks rebind can't silently revert.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. Module API: switch/close_tabs/switch_to are functions.
run_nv -c 'lua local m = require("plugins.configs.worktree"); for _, n in ipairs({ "switch", "close_tabs", "switch_to" }) do if type(m[n]) ~= "function" then print("missing worktree API: " .. n); vim.cmd("cquit") end end' -c qa

# 2. close_tabs with a single tab (headless default) degrades cleanly: notify +
#    return, no picker, no error.
run_nv -c 'lua local m = require("plugins.configs.worktree"); local ok, err = pcall(m.close_tabs); if not ok then print("close_tabs errored on single-tab case: " .. tostring(err)); vim.cmd("cquit") end' -c qa

# 3. <leader>gws / <leader>gwq are mapped (lazy keys) to the Snacks pickers,
#    with descs that pin them to Snacks rather than the old telescope wording.
run_nv -c 'lua local d = vim.fn.maparg(" gws", "n", false, true); if type(d) ~= "table" or d.desc ~= "Worktree: switch (Snacks)" then print("<leader>gws missing/wrong desc: " .. tostring(d and d.desc)); vim.cmd("cquit") end' -c qa
run_nv -c 'lua local d = vim.fn.maparg(" gwq", "n", false, true); if type(d) ~= "table" or d.desc ~= "Worktree: close tabs (Snacks, multi-select)" then print("<leader>gwq missing/wrong desc: " .. tostring(d and d.desc)); vim.cmd("cquit") end' -c qa
