#!/usr/bin/env bash
#
# brain-watch.sh — always-on local sync loop.
#
# Runs the same safe sequence as _refresh.sh on a poll interval. Do NOT swap
# this for a plain `gbrain sync --watch`: its incremental pass deletes code
# pages from the brain (see _refresh.sh). Coverage: .brain/ notes are picked
# up within one interval even uncommitted (`gbrain import` reads the working
# tree); code refreshes per commit (the code sync is commit-to-commit).
# Pair with the git hooks (which handle commit/merge/checkout). Both are
# idempotent — overlap is safe.
#
# Usage:
#   .githooks/brain-watch.sh                 # foreground (Ctrl-C to stop)
#   .githooks/brain-watch.sh --interval 30   # custom poll interval (seconds)
set -uo pipefail

REPO="${REPO:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
if [ -z "$REPO" ]; then
  echo "error: not in a git repo and REPO not set" >&2; exit 1
fi
# GBRAIN_HOME is the parent dir; the brain lives at $GBRAIN_HOME/.gbrain/.
export GBRAIN_HOME="$REPO"

if [ ! -f "$GBRAIN_HOME/.gbrain/config.json" ]; then
  echo "error: no brain at $GBRAIN_HOME/.gbrain (run .githooks/setup.sh first)" >&2; exit 1
fi

INTERVAL=60
if [ "${1:-}" = "--interval" ] && [ -n "${2:-}" ]; then
  INTERVAL="$2"
fi

echo "repo-brain watcher: $REPO (poll ${INTERVAL}s, GBRAIN_HOME=$GBRAIN_HOME)"
while true; do
  gbrain sync --strategy code --repo "$REPO" --no-pull --no-embed --yes \
    || echo "code sync failed ($?), retrying next interval..." >&2
  [ -d "$REPO/.brain" ] && { gbrain import "$REPO/.brain" --no-embed \
    || echo "notes import failed ($?), retrying next interval..." >&2; }
  gbrain embed --stale || echo "embed failed ($?), retrying next interval..." >&2
  sleep "$INTERVAL"
done
