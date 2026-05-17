#!/usr/bin/env bash
# Coverage for plugins.configs.worktree.workflow_prompt:
# - default built-in prompt is returned when nothing is overridden
# - vim.g.claude_worktree_prompt = string overrides
# - vim.g.claude_worktree_prompt = false disables
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. API exists
run_nv -c 'lua local m = require("plugins.configs.worktree"); if type(m.workflow_prompt) ~= "function" then print("missing: workflow_prompt"); vim.cmd("cquit") end' -c qa

# 2. Default: non-empty string mentioning "gh pr create"
run_nv -c 'lua local m = require("plugins.configs.worktree"); local got = m.workflow_prompt(); if type(got) ~= "string" or not got:find("gh pr create", 1, true) then print("default prompt missing or wrong, got: " .. tostring(got)); vim.cmd("cquit") end' -c qa

# 3. g: string override wins
run_nv -c 'lua vim.g.claude_worktree_prompt = "RULE-XYZ"; local m = require("plugins.configs.worktree"); local got = m.workflow_prompt(); if got ~= "RULE-XYZ" then print("override failed, got: " .. tostring(got)); vim.cmd("cquit") end' -c qa

# 4. g: false disables, returns nil
run_nv -c 'lua vim.g.claude_worktree_prompt = false; local m = require("plugins.configs.worktree"); local got = m.workflow_prompt(); if got ~= nil then print("disable failed, got: " .. tostring(got)); vim.cmd("cquit") end' -c qa

# 5. g: empty string falls back to default
run_nv -c 'lua vim.g.claude_worktree_prompt = ""; local m = require("plugins.configs.worktree"); local got = m.workflow_prompt(); if type(got) ~= "string" or not got:find("gh pr create", 1, true) then print("empty g: should fall back to default, got: " .. tostring(got)); vim.cmd("cquit") end' -c qa
