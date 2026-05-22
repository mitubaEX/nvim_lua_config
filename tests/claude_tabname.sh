#!/usr/bin/env bash
# Coverage for common.claude_tabname:
# - module loads from init.lua and exposes its API
# - osc() emits OSC 0 + OSC 2 with BEL terminators
# - compose() maps running / attention / no-session to 🤖 / 🔔 / bare branch
# - update() is a harmless no-op when headless (no UI to title)
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. API exists (module is required by init.lua at startup).
run_nv -c 'lua local m = require("common.claude_tabname"); for _, fn in ipairs({"osc","compose","current_title","update","setup"}) do if type(m[fn]) ~= "function" then print("missing: " .. fn); vim.cmd("cquit") end end' -c qa

# 2. osc() is exactly OSC 0 (icon+title) then OSC 2 (title), each BEL-terminated.
run_nv -c 'lua local m = require("common.claude_tabname"); local esc, bel = string.char(27), string.char(7); local want = esc .. "]0;X" .. bel .. esc .. "]2;X" .. bel; local got = m.osc("X"); if got ~= want then print("osc mismatch: " .. vim.inspect(got)); vim.cmd("cquit") end' -c qa

# 3. compose(): running -> 🤖, attention -> 🔔, nil -> bare branch.
run_nv -c 'lua local m = require("common.claude_tabname"); local cases = {{"running","🤖 br"},{"attention","🔔 br"},{false,"br"}}; for _, c in ipairs(cases) do local state = c[1] or nil; local got = m.compose("br", state); if got ~= c[2] then print("compose("..tostring(c[1])..") = "..tostring(got)); vim.cmd("cquit") end end' -c qa

# 4. update() must not error in headless (can_emit() is false -> no terminal write).
run_nv -c 'lua local ok, err = pcall(require("common.claude_tabname").update); if not ok then print("update errored: " .. tostring(err)); vim.cmd("cquit") end' -c qa
