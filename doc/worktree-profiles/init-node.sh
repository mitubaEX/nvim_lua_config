#!/usr/bin/env bash
# Post-create hook for a Node / React worktree.
# Usage: copy to repo root as `.worktree-init.sh`, mark executable.
#   :GitWorktreeCreate feature/foo --command "!./.worktree-init.sh"

set -euo pipefail

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv export bash 2>/dev/null || true)"
fi

if [ -f pnpm-lock.yaml ]; then
  echo "==> pnpm install"
  pnpm install --silent
elif [ -f yarn.lock ]; then
  echo "==> yarn install"
  yarn install --silent
elif [ -f package-lock.json ]; then
  echo "==> npm ci"
  npm ci --silent
else
  echo "No lockfile found, skipping install"
fi

# Seed local env if a sample exists and the worktree doesn't have one yet.
if [ -f .env.example ] && [ ! -f .env.local ]; then
  cp .env.example .env.local
  echo "==> copied .env.example -> .env.local"
fi

echo "Node worktree ready. PORT=${PORT:-3000}"
