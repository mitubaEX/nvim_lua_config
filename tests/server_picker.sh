#!/usr/bin/env bash
# Server list/logs run on Snacks now (plugins.configs.server_picker), replacing
# server.nvim's telescope extension. Cover the module API, the lazy-loaded
# <Leader>fs / <Leader>fsl entry points, the empty-logs degrade path, and the
# server.nvim core API the picker drives directly.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. Module API: servers/logs are functions.
run_nv -c 'lua local ok, m = pcall(require, "plugins.configs.server_picker"); if not ok or type(m) ~= "table" then print("require server_picker failed: " .. tostring(m)); vim.cmd("cquit") end; for _, n in ipairs({ "servers", "logs" }) do if type(m[n]) ~= "function" then print("missing server_picker API: " .. n); vim.cmd("cquit") end end' -c qa

# 2. <Leader>fs / <Leader>fsl are mapped (lazy keys that load server.nvim) with
#    their descs, so the picker entry points can't silently disappear.
run_nv -c 'lua local d = vim.fn.maparg(" fs", "n", false, true); if type(d) ~= "table" or d.desc ~= "Server list" then print("<Leader>fs missing/wrong desc: " .. tostring(d and d.desc)); vim.cmd("cquit") end' -c qa
run_nv -c 'lua local d = vim.fn.maparg(" fsl", "n", false, true); if type(d) ~= "table" or d.desc ~= "Server logs" then print("<Leader>fsl missing/wrong desc: " .. tostring(d and d.desc)); vim.cmd("cquit") end' -c qa

# 3. logs() with nothing running degrades cleanly (notify + return): no picker,
#    no error, so it is safe to call headless.
run_nv -c 'lua local m = require("plugins.configs.server_picker"); local ok, err = pcall(m.logs); if not ok then print("logs() errored on empty case: " .. tostring(err)); vim.cmd("cquit") end' -c qa

# 4. server.nvim exposes the core API the picker drives (no telescope needed).
run_nv -c 'lua local ok, c = pcall(require, "server.config"); local ok2, s = pcall(require, "server.servers"); if not (ok and ok2) then print("server.nvim core API unavailable"); vim.cmd("cquit") end; if type(c.get_server_names) ~= "function" or type(s.get_logs) ~= "function" then print("server core API shape changed"); vim.cmd("cquit") end' -c qa
