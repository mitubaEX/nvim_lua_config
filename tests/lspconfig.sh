#!/usr/bin/env bash
# Regression: plugins/configs/lspconfig.lua must not use vim.lsp.with
# (removed in nvim nightly). It crashed on LspAttach when present.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

FILE="$REPO_ROOT/.config/nvim/lua/plugins/configs/lspconfig.lua"

if grep -nE 'vim\.lsp\.with\b' "$FILE"; then
  echo "lspconfig.lua still references removed vim.lsp.with" >&2
  exit 1
fi
