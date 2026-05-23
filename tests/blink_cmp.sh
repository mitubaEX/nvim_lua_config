#!/usr/bin/env bash
# Regression: completion runs on blink.cmp (migrated off nvim-cmp), and LSP
# capabilities are sourced from blink.cmp.get_lsp_capabilities() instead of
# cmp_nvim_lsp. Guards both the spec (static greps) and runtime behavior.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

COMPLETION="$REPO_ROOT/.config/nvim/lua/plugins/completion.lua"
LSPCONFIG="$REPO_ROOT/.config/nvim/lua/plugins/configs/lspconfig.lua"

# --- static guards -----------------------------------------------------------
grep -q 'saghen/blink.cmp' "$COMPLETION" \
  || { echo "completion.lua no longer references blink.cmp" >&2; exit 1; }
if grep -qE 'hrsh7th/nvim-cmp|require\("cmp"\)' "$COMPLETION"; then
  echo "completion.lua still references nvim-cmp" >&2; exit 1
fi
grep -q 'blink.cmp' "$LSPCONFIG" && grep -q 'get_lsp_capabilities' "$LSPCONFIG" \
  || { echo "lspconfig.lua does not source capabilities from blink.cmp" >&2; exit 1; }
if grep -qE 'require\([^)]*cmp_nvim_lsp' "$LSPCONFIG"; then
  echo "lspconfig.lua still requires cmp_nvim_lsp" >&2; exit 1
fi

# --- headless behavior -------------------------------------------------------
# Requiring blink.cmp force-loads the lazy plugin (it is event = InsertEnter),
# which runs setup() and populates blink.cmp.config from our opts. Kept on one
# physical line: backslash-newline is literal inside single quotes, so a
# multi-line chunk would reach nvim with stray '\'.
run_nv -c 'lua local ok, blink = pcall(require, "blink.cmp"); if not ok then print("blink.cmp failed to load: " .. tostring(blink)); vim.cmd("cquit") end; local caps = blink.get_lsp_capabilities(); if type(caps) ~= "table" or not (caps.textDocument and caps.textDocument.completion) then print("get_lsp_capabilities missing completion capability"); vim.cmd("cquit") end; local cfg = require("blink.cmp.config"); for _, lhs in ipairs({ "<C-j>", "<C-k>", "<CR>" }) do if cfg.keymap[lhs] == nil then print("blink keymap missing: " .. lhs); vim.cmd("cquit") end end; if cfg.sources.providers.lsp.name ~= "[LSP]" or cfg.sources.providers.buffer.name ~= "[Buffer]" then print("blink provider labels not preserved"); vim.cmd("cquit") end; if pcall(require, "cmp") then print("nvim-cmp (require cmp) is still loadable"); vim.cmd("cquit") end' -c qa
