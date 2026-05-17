#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
for t in tests/[0-9]*-*.sh tests/[a-z]*.sh; do
  [ -f "$t" ] || continue
  [ "$t" = "tests/lib.sh" ] && continue
  [ "$t" = "tests/run.sh" ] && continue
  printf '== %s ==\n' "$t"
  if ! bash "$t"; then
    echo "FAIL: $t"
    fail=1
  fi
done
exit "$fail"
