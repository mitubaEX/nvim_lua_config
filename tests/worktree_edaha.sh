#!/usr/bin/env bash
# Coverage for plugins.configs.worktree edaha task flow:
# - create_with_edaha_task / create_from_default_with_edaha_task exist
# - the namer (_namer_edaha) receives the task text from vim.ui.input
# - on namer failure, vim.notify is called at ERROR level and
#   GitWorktreeCreate is NOT executed
# - on success the suggested branch name becomes the default of the
#   confirmation vim.ui.input, and GitWorktreeCreate runs with it
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. API exists
run_nv -c 'lua local m = require("plugins.configs.worktree"); for _, k in ipairs({"create_with_edaha_task","create_from_default_with_edaha_task","_namer_edaha"}) do if m[k] == nil then print("missing: " .. k); vim.cmd("cquit") end end' -c qa

# 2. Happy path: namer stub receives the task, confirm input defaults to the
#    suggested branch, GitWorktreeCreate runs with the confirmed branch, and
#    claude_workflow.open is called with prompt = task.
run_nv -c 'lua
  local m = require("plugins.configs.worktree")

  -- stub: ui.input feeds the two prompts in order
  local inputs = { "日本語タスク", nil } -- 2nd filled from default
  local idx = 0
  local default_seen
  vim.ui.input = function(opts, cb)
    idx = idx + 1
    if idx == 1 then cb(inputs[1]) else default_seen = opts.default; cb(opts.default) end
  end

  -- stub: namer captures the task and returns a fake branch
  local namer_seen
  m._namer_edaha = function(task) namer_seen = task; return "feat/from-stub" end

  -- stub: capture vim.cmd calls
  local cmds = {}
  local real_cmd = vim.cmd
  vim.cmd = setmetatable({}, { __call = function(_, c) cmds[#cmds+1] = c end })

  -- stub claude_workflow before the function runs
  package.loaded["claude_workflow"] = {
    open = function(opts) _G.__claude_opts = opts end,
  }

  m.create_with_edaha_task()

  vim.cmd = real_cmd

  if namer_seen ~= "日本語タスク" then print("namer not called with task, got: " .. tostring(namer_seen)); vim.cmd("cquit") end
  if default_seen ~= "feat/from-stub" then print("confirm input default mismatch: " .. tostring(default_seen)); vim.cmd("cquit") end
  local found
  for _, c in ipairs(cmds) do if c:find("^GitWorktreeCreate feat/from%-stub") then found = c end end
  if not found then print("GitWorktreeCreate not invoked with branch, cmds: " .. vim.inspect(cmds)); vim.cmd("cquit") end
  if found:find("--from-default") then print("unexpected --from-default in non-default path: " .. found); vim.cmd("cquit") end
  if not _G.__claude_opts or _G.__claude_opts.prompt ~= "日本語タスク" then print("claude.open prompt mismatch: " .. vim.inspect(_G.__claude_opts)); vim.cmd("cquit") end
' -c qa

# 3. from_default variant adds --from-default
run_nv -c 'lua
  local m = require("plugins.configs.worktree")
  local idx = 0
  vim.ui.input = function(opts, cb)
    idx = idx + 1
    if idx == 1 then cb("X") else cb(opts.default) end
  end
  m._namer_edaha = function() return "b" end
  local cmds = {}
  local real_cmd = vim.cmd
  vim.cmd = setmetatable({}, { __call = function(_, c) cmds[#cmds+1] = c end })
  package.loaded["claude_workflow"] = { open = function() end }
  m.create_from_default_with_edaha_task()
  vim.cmd = real_cmd
  local found
  for _, c in ipairs(cmds) do if c:find("^GitWorktreeCreate b %-%-from%-default") then found = true end end
  if not found then print("--from-default missing, cmds: " .. vim.inspect(cmds)); vim.cmd("cquit") end
' -c qa

# 4. Namer failure: ERROR notify fires, GitWorktreeCreate is NOT run
run_nv -c 'lua
  local m = require("plugins.configs.worktree")
  vim.ui.input = function(_, cb) cb("task") end
  m._namer_edaha = function() return nil, "boom" end
  local notes = {}
  vim.notify = function(msg, lvl) notes[#notes+1] = { msg = msg, lvl = lvl } end
  local cmds = {}
  local real_cmd = vim.cmd
  vim.cmd = setmetatable({}, { __call = function(_, c) cmds[#cmds+1] = c end })
  m.create_with_edaha_task()
  vim.cmd = real_cmd
  local err_seen
  for _, n in ipairs(notes) do
    if n.lvl == vim.log.levels.ERROR and tostring(n.msg):find("boom") then err_seen = true end
  end
  if not err_seen then print("expected ERROR notify with boom, notes: " .. vim.inspect(notes)); vim.cmd("cquit") end
  for _, c in ipairs(cmds) do
    if c:find("^GitWorktreeCreate") then print("worktree should not be created on namer failure: " .. c); vim.cmd("cquit") end
  end
' -c qa

# 5. keymaps are registered
assert_keymap_exists n "<leader>gwe"
assert_keymap_exists n "<leader>gwE"
