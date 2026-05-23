#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Style: scope to the config tree so any vendored/generated Lua elsewhere can't
# fail the check for unrelated reasons (and failures point at our files).
if command -v stylua >/dev/null 2>&1; then
  stylua --check .config/nvim/lua .config/nvim/init.lua
else
  echo "stylua not found, skipping style check"
fi

# Syntax: `luac -p` is a cheap parse-only check. Note system luac is usually
# Lua 5.4 while Neovim runs LuaJIT (5.1); for plain parsing the dialects rarely
# diverge, but if luac ever false-flags valid LuaJIT syntax, swap in a
# nvim-side parse instead (slower, executes the file, so beware side effects):
#   find .config/nvim -name '*.lua' -print0 \
#     | xargs -0 -I{} nvim --headless --clean -c 'luafile {}' -c qa
find .config/nvim -name '*.lua' -print0 | xargs -0 -n1 luac -p
