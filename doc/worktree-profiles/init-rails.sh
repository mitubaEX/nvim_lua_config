#!/usr/bin/env bash
# Post-create hook for a Rails worktree.
# Usage: copy to repo root as `.worktree-init.sh`, mark executable.
# Run it from nvim:
#   :GitWorktreeCreate feature/foo --command "!./.worktree-init.sh"

set -euo pipefail

# Pick up .envrc-derived vars (DATABASE_URL, PORT, ...).
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv export bash 2>/dev/null || true)"
fi

echo "==> bundle install"
bundle install --quiet

echo "==> yarn/pnpm install (assets)"
if [ -f pnpm-lock.yaml ]; then
  pnpm install --silent
elif [ -f yarn.lock ]; then
  yarn install --silent
elif [ -f package-lock.json ]; then
  npm install --silent
fi

echo "==> db:prepare"
bin/rails db:prepare

echo "Rails worktree ready. PORT=${PORT:-3000}"
