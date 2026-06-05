#!/usr/bin/env bash
#
# brain-watch.sh — always-on local sync for working-tree edits.
#
# Wraps `gbrain sync --watch` (a 60s polling loop) so uncommitted changes get
# indexed too, not just commits. gbrain's --watch exits after 5 consecutive
# failures, so this wrapper restarts it. Pair with the git hooks (which handle
# commit/merge/checkout). Both are idempotent — overlap is safe.
#
# Usage:
#   .githooks/brain-watch.sh                 # foreground (Ctrl-C to stop)
#   .githooks/brain-watch.sh --interval 30   # custom poll interval (seconds)
set -uo pipefail

REPO="${REPO:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
if [ -z "$REPO" ]; then
  echo "error: not in a git repo and REPO not set" >&2; exit 1
fi
export GBRAIN_HOME="$REPO/.gbrain"

if [ ! -f "$GBRAIN_HOME/config.json" ]; then
  echo "error: no brain at $GBRAIN_HOME (run .githooks/setup.sh first)" >&2; exit 1
fi

INTERVAL=60
if [ "${1:-}" = "--interval" ] && [ -n "${2:-}" ]; then
  INTERVAL="$2"
fi

echo "repo-brain watcher: $REPO (poll ${INTERVAL}s, GBRAIN_HOME=$GBRAIN_HOME)"
while true; do
  gbrain sync --watch --repo "$REPO" --interval "$INTERVAL" \
    || echo "watcher exited ($?), restarting in 10s..." >&2
  sleep 10
done
