#!/usr/bin/env bash
# One-time (and CI) prep: install every plugin into the repo-local data dir so
# run.sh can load them without depending on ~/.local/share/nvim. Safe to
# re-run; lazy.nvim only fetches what is missing or outdated.
#
# Kept separate from run.sh on purpose: the test run must never sync over the
# network. run.sh excludes this file so it is not picked up as a test.
set -euo pipefail
cd "$(dirname "$0")/.."
source "$(dirname "$0")/lib.sh"

# init.lua bootstraps lazy.nvim itself on first launch; `Lazy! sync` then
# installs/updates the rest of the spec. The bang runs it synchronously so the
# subsequent `qa` only fires once install has finished.
run_nv -c 'Lazy! sync' -c qa
