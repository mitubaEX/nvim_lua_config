#!/usr/bin/env bash
# Regression: config/treesitter_compat.lua must (a) unwrap the new
# Neovim 0.10+ TSMatch shape (TSNode[]) and (b) re-register the directives
# that crash vim-matchup with E5108 ("attempt to call method 'range' on nil").
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

tmp_lua="$(mktemp -t treesitter_compat.XXXXXX.lua)"
trap 'rm -f "$tmp_lua"' EXIT

cat >"$tmp_lua" <<'LUA'
vim.opt.runtimepath:prepend(os.getenv("REPO_ROOT") .. "/.config/nvim")

local ok, m = pcall(require, "config.treesitter_compat")
if not ok then
  io.stderr:write("require failed: " .. tostring(m))
  os.exit(1)
end
if type(m) ~= "table" or type(m.apply) ~= "function" then
  io.stderr:write("apply must be a function on the returned table")
  os.exit(1)
end

-- _pick_node は本修正の核。archived nvim-treesitter は match[id] を単一 TSNode
-- 扱いしてクラッシュしたので、新形式 (TSNode[]) を末尾要素として剥がせること、
-- 旧 API/外部呼び出しで単一 userdata が来ても passthrough すること、
-- nil/空リストでも安全であることを担保する。TSNode は userdata なので
-- newproxy で「table ではない値」を作って単一ケースを模す。
local pn = m._pick_node
assert(pn(nil) == nil, "nil should pass through")
local fake_single_node = newproxy(false)
assert(pn(fake_single_node) == fake_single_node, "userdata-like single value should pass through")
local last = "LAST_NODE"
assert(pn({ "FIRST_NODE", last }) == last, "TSNode[] should return last")
assert(pn({}) == nil, "empty list should yield nil")

-- apply() は実 Neovim treesitter API に対してエラーを出さず、
-- lazy.nvim の reload 等で 2 回呼ばれても壊れない (冪等) こと。
m.apply()
m.apply()

print("OK")
LUA

out=$(REPO_ROOT="$REPO_ROOT" nvim --headless --clean -n -l "$tmp_lua" 2>&1)
if ! grep -q "^OK$" <<<"$out"; then
  echo "treesitter_compat regression test failed:" >&2
  echo "$out" >&2
  exit 1
fi
