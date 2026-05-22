#!/usr/bin/env bash
# `;` lists only the current tab's buffers via telescope's builtin
# (cwd_only). Each tab is :tcd-pinned to a worktree, so this scopes the buffer
# list per worktree without custom state. Guard the keymap rebind so it can't
# silently revert to the global buffer list (the old `<cmd>Telescope buffers`).
set -euo pipefail
source "$(dirname "$0")/lib.sh"

run_nv \
  -c 'lua local d = vim.fn.maparg(";", "n", false, true); if not (type(d) == "table" and d.callback) then print("; not mapped to a callback"); vim.cmd("cquit") end; if d.desc ~= "Buffers in current tab cwd" then print("unexpected ; desc: " .. tostring(d.desc)); vim.cmd("cquit") end' \
  -c qa
