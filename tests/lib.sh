#!/usr/bin/env bash
# Common helpers for nvim headless tests.
#
# run_nv runs the repo's own init.lua but pins every XDG dir inside the repo,
# so tests exercise the real config without touching (or depending on) the
# host's ~/.local/share/nvim. Plugins must already live in the repo-local data
# dir: run `bash tests/setup.sh` once (it does `Lazy! sync`). run.sh assumes
# that prep is done and never installs anything itself.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_nv() {
  XDG_CONFIG_HOME="$REPO_ROOT/.config" \
  XDG_DATA_HOME="$REPO_ROOT/.local/share" \
  XDG_STATE_HOME="$REPO_ROOT/.local/state" \
  XDG_CACHE_HOME="$REPO_ROOT/.cache" \
    nvim --headless -u "$REPO_ROOT/.config/nvim/init.lua" "$@"
}

# assert_cmd_exists <Command>          # no leading ':'
# assert_keymap_exists <mode> <lhs>
# Both print a reason and cquit (non-zero exit) when the check fails. Use them
# for plain "does it exist" guards. For anything richer (desc/callback/rhs,
# prefix-collision checks) prefer an inline `-c 'lua ...'`; the shell quoting
# below gets fragile fast once <lhs> contains quotes or backslashes.
assert_cmd_exists() {
  local cmd="$1"
  run_nv -c "lua if vim.fn.exists(':$cmd') ~= 2 then print('missing command: $cmd'); vim.cmd('cquit') end" -c qa
}

assert_keymap_exists() {
  local mode="$1" lhs="$2"
  run_nv -c "lua if vim.fn.maparg('$lhs', '$mode') == '' then print('missing keymap: $mode $lhs'); vim.cmd('cquit') end" -c qa
}

export -f run_nv assert_cmd_exists assert_keymap_exists
export REPO_ROOT
