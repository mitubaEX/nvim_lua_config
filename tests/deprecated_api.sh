#!/usr/bin/env bash
# Regression: keep the config free of nvim APIs deprecated by 0.11/0.12-dev.
# Each emits a deprecation warning (and is scheduled for removal):
#   - vim.loop.*       -> use (vim.uv or vim.loop)
#   - vim.api.nvim_{buf,win}_{get,set}_option / nvim_{get,set}_option
#                      -> use vim.bo / vim.wo / vim.o (or nvim_*_option_value)
#   - vim.highlight.*  -> renamed to the vim.hl namespace in 0.11
#   - vim.diagnostic.goto_{next,prev} -> vim.diagnostic.jump({ count = ±1 })
# The (vim.uv or vim.loop) and (vim.hl or vim.highlight) fallback forms are
# allowed; only the bare deprecated access is rejected. nvim_*_option_value is
# the modern form and is intentionally not matched (the \b stops before "_value").
set -euo pipefail
source "$(dirname "$0")/lib.sh"

ROOT="$REPO_ROOT/.config/nvim"
status=0

report() {
  echo "deprecated API still present ($1):" >&2
  echo "$2" >&2
  status=1
}

hits="$(grep -rnE 'vim\.loop\b' "$ROOT/init.lua" "$ROOT/lua" | grep -v 'vim\.uv or vim\.loop' || true)"
[ -n "$hits" ] && report "vim.loop -> (vim.uv or vim.loop)" "$hits"

hits="$(grep -rnE 'nvim_(buf|win)_(get|set)_option\b|nvim_(get|set)_option\b' "$ROOT/init.lua" "$ROOT/lua" || true)"
[ -n "$hits" ] && report "nvim_*_option -> vim.bo/vim.wo/vim.o" "$hits"

hits="$(grep -rnE 'vim\.highlight\b' "$ROOT/init.lua" "$ROOT/lua" | grep -v 'vim\.hl or vim\.highlight' || true)"
[ -n "$hits" ] && report "vim.highlight -> vim.hl" "$hits"

hits="$(grep -rnE 'vim\.diagnostic\.goto_(next|prev)\b' "$ROOT/init.lua" "$ROOT/lua" || true)"
[ -n "$hits" ] && report "vim.diagnostic.goto_next/prev -> vim.diagnostic.jump" "$hits"

exit "$status"
