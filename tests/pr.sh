#!/usr/bin/env bash
# Coverage for lua/plugins/configs/pr.lua + lua/common/pr.lua.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. module require
run_nv -c 'lua local ok, m = pcall(require, "plugins.configs.pr"); if not ok or type(m) ~= "table" then print("require failed: " .. tostring(m)); vim.cmd("cquit") end' -c qa

# 2. public API
run_nv -c 'lua local m = require("plugins.configs.pr"); for _, n in ipairs({"create", "create_with_claude_review", "request_review", "review_prompt", "current_pr", "view", "status"}) do if type(m[n]) ~= "function" then print("missing: " .. n); vim.cmd("cquit") end end' -c qa

# 3. review_prompt formats the PR number (deterministic, no IO)
run_nv -c 'lua local m = require("plugins.configs.pr"); local got = m.review_prompt(42); if not got:find("PR #42", 1, true) then print("review_prompt missing PR number, got: " .. got); vim.cmd("cquit") end; if not got:find("gh pr diff 42", 1, true) then print("review_prompt missing diff cmd, got: " .. got); vim.cmd("cquit") end' -c qa

# 4. user commands registered (init.lua requires common.pr at startup)
run_nv -c 'lua for _, c in ipairs({"PRCreate", "PRCreateReview", "PRView", "PRStatus", "PRReview"}) do if vim.fn.exists(":" .. c) ~= 2 then print("missing user cmd: " .. c); vim.cmd("cquit") end end' -c qa

# 5. keymaps registered (note: <leader> -> space in maparg)
run_nv -c 'lua for _, lhs in ipairs({" gpc", " gpC", " gpd", " gpv", " gps", " gpr"}) do local rhs = vim.fn.maparg(lhs, "n"); if rhs == "" then print("missing keymap: " .. lhs); vim.cmd("cquit") end end' -c qa
