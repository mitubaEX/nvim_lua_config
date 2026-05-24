#!/usr/bin/env bash
# Telescope -> Snacks.picker migration, completed (issues #49 + remove_telescope).
#
# The `;` (current-tab buffers) and `<Leader>;` / :TerminalBuffers (terminal
# buffers) pickers run on Snacks.picker, scoped by handing Snacks an explicit
# bufnr allowlist via its `filter.filter` predicate. telescope is now removed
# entirely: file/grep/buffer and worktree pickers are all on Snacks.
# Guard the spec (static greps) and the runtime registration so the pickers
# can't silently revert to telescope.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

CONFIG="$REPO_ROOT/.config/nvim/lua"
PICKERS="$CONFIG/plugins/configs/pickers.lua"

# --- static guards -----------------------------------------------------------
# Snacks-backed pickers, scoped via the tab-buffer allowlist + Snacks filter.
grep -q 'Snacks.picker.buffers' "$PICKERS" \
	|| { echo "pickers.lua no longer uses Snacks.picker.buffers" >&2; exit 1; }
grep -q 'current_tab_bufnrs' "$PICKERS" \
	|| { echo "pickers.lua dropped the per-tab scoping (current_tab_bufnrs)" >&2; exit 1; }
grep -q 'filter' "$PICKERS" \
	|| { echo "pickers.lua dropped the Snacks filter (scoping is gone)" >&2; exit 1; }

# telescope must be gone from the config tree: no leftover config module and no
# `require("telescope")` / telescope.* picker building blocks anywhere.
if [ -e "$CONFIG/plugins/configs/telescope.lua" ]; then
	echo "telescope.lua still present (telescope not fully removed)" >&2; exit 1
fi
if grep -rqE 'require\(["'\'']telescope|telescope\.(pickers|finders|actions|config|builtin)|load_extension' "$CONFIG"; then
	echo "config still references telescope (require/pickers/extensions)" >&2; exit 1
fi
# No telescope plugin spec / dependency / :Telescope keymap left behind.
if grep -rqE 'nvim-telescope/telescope|<cmd>Telescope|Telescope server' "$CONFIG"; then
	echo "a telescope plugin spec or :Telescope keymap is still wired up" >&2; exit 1
fi

# --- headless behavior -------------------------------------------------------
# Module API.
run_nv -c 'lua local ok, m = pcall(require, "plugins.configs.pickers"); if not ok or type(m) ~= "table" then print("require pickers failed: " .. tostring(m)); vim.cmd("cquit") end; for _, n in ipairs({ "setup", "pick_tab_buffers", "pick_terminal_buffers" }) do if type(m[n]) ~= "function" then print("missing pickers API: " .. n); vim.cmd("cquit") end end' -c qa

# Snacks (lazy = false) is up at startup and exposes the picker we delegate to,
# so the keymap callbacks are not no-ops.
run_nv -c 'lua if type(Snacks) ~= "table" or type(Snacks.picker) ~= "table" or type(Snacks.picker.buffers) ~= "function" then print("Snacks.picker.buffers unavailable at startup"); vim.cmd("cquit") end' -c qa

# `;` is a callback (the Snacks tab picker), not the old `<cmd>Telescope ...`,
# and keeps its desc so the rebind can't silently revert.
run_nv -c 'lua local d = vim.fn.maparg(";", "n", false, true); if not (type(d) == "table" and d.callback) then print("; not mapped to a callback"); vim.cmd("cquit") end; if d.desc ~= "Buffers in current tab" then print("unexpected ; desc: " .. tostring(d.desc)); vim.cmd("cquit") end' -c qa

# `<Leader>;` is the terminal-buffer picker callback.
run_nv -c 'lua local d = vim.fn.maparg(" ;", "n", false, true); if not (type(d) == "table" and d.callback) then print("<Leader>; not mapped to a callback"); vim.cmd("cquit") end' -c qa

# Command renamed off "Telescope": :TerminalBuffers exists, the old name is gone.
run_nv -c 'lua if vim.fn.exists(":TerminalBuffers") ~= 2 then print("TerminalBuffers command not registered"); vim.cmd("cquit") end; if vim.fn.exists(":TelescopeTerminals") == 2 then print("stale TelescopeTerminals command still registered"); vim.cmd("cquit") end' -c qa

# telescope is removed: it must never end up loaded, even after startup.
run_nv -c 'lua if package.loaded["telescope"] ~= nil then print("telescope is loaded (should be fully removed)"); vim.cmd("cquit") end' -c qa

# Terminal picker degrades cleanly when there are no terminal buffers: it must
# notify and return without opening a picker (so this is safe to call headless).
run_nv -c 'lua local m = require("plugins.configs.pickers"); local ok, err = pcall(m.pick_terminal_buffers); if not ok then print("pick_terminal_buffers errored on empty case: " .. tostring(err)); vim.cmd("cquit") end' -c qa
