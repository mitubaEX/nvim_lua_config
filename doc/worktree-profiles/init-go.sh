#!/usr/bin/env bash
# Post-create hook for a Go worktree.
# Usually unnecessary — Go's module/build caches are global.
# Use only if you want to pre-warm dependencies.

set -euo pipefail

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv export bash 2>/dev/null || true)"
fi

echo "==> go mod download"
go mod download

echo "Go worktree ready. PORT=${PORT:-8000}"
