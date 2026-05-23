#!/usr/bin/env bash
# Telescope -> Snacks.picker migration (issue #49).
#
# The `;` (current-tab buffers) and `<Leader>;` / :TerminalBuffers (terminal
# buffers) pickers run on Snacks.picker now, scoped by handing Snacks an
# explicit bufnr allowlist via its `filter.filter` predicate. telescope keeps
# only the worktree pickers + git_worktree/server extensions and loads lazily.
# Guard the spec (static greps) and the runtime registration so the pickers
# can't silently revert to telescope.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

PICKERS="$REPO_ROOT/.config/nvim/lua/plugins/configs/pickers.lua"
TELESCOPE="$REPO_ROOT/.config/nvim/lua/plugins/configs/telescope.lua"
EDITOR="$REPO_ROOT/.config/nvim/lua/plugins/editor.lua"

# --- static guards -----------------------------------------------------------
# Snacks-backed pickers, scoped via the tab-buffer allowlist + Snacks filter.
grep -q 'Snacks.picker.buffers' "$PICKERS" \
	|| { echo "pickers.lua no longer uses Snacks.picker.buffers" >&2; exit 1; }
grep -q 'current_tab_bufnrs' "$PICKERS" \
	|| { echo "pickers.lua dropped the per-tab scoping (current_tab_bufnrs)" >&2; exit 1; }
grep -q 'filter' "$PICKERS" \
	|| { echo "pickers.lua dropped the Snacks filter (scoping is gone)" >&2; exit 1; }

# The custom telescope buffer picker must be gone from telescope.lua.
if grep -qE 'telescope\.(pickers|finders)|pick_buffers|pick_tab_buffers|pick_terminal_buffers' "$TELESCOPE"; then
	echo "telescope.lua still hand-rolls a telescope buffer picker" >&2; exit 1
fi
# telescope is kept only for the extensions with no Snacks equivalent.
grep -q 'load_extension("git_worktree")' "$TELESCOPE" \
	&& grep -q 'load_extension("server")' "$TELESCOPE" \
	|| { echo "telescope.lua no longer loads the git_worktree/server extensions" >&2; exit 1; }

# telescope must be lazy now (no `lazy = false` on its spec). Scope the grep to
# the telescope spec block so snacks' own `lazy = false` doesn't mask a regression.
if awk '/"nvim-telescope\/telescope.nvim"/{f=1} f&&/lazy = false/{print; exit} /folke\/snacks.nvim/{f=0}' "$EDITOR" | grep -q 'lazy = false'; then
	echo "telescope.nvim spec is still lazy = false (migration incomplete)" >&2; exit 1
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

# telescope is lazy: nothing at startup should have loaded it.
run_nv -c 'lua if package.loaded["telescope"] ~= nil then print("telescope loaded at startup (should be lazy)"); vim.cmd("cquit") end' -c qa

# Terminal picker degrades cleanly when there are no terminal buffers: it must
# notify and return without opening a picker (so this is safe to call headless).
run_nv -c 'lua local m = require("plugins.configs.pickers"); local ok, err = pcall(m.pick_terminal_buffers); if not ok then print("pick_terminal_buffers errored on empty case: " .. tostring(err)); vim.cmd("cquit") end' -c qa
