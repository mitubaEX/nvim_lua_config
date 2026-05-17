#!/usr/bin/env bash
# Common helpers for nvim headless tests.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_nv() {
  XDG_CONFIG_HOME="$REPO_ROOT/.config" \
    nvim --headless --clean -u "$REPO_ROOT/.config/nvim/init.lua" "$@"
}
export -f run_nv
export REPO_ROOT
