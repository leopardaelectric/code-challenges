#!/usr/bin/env bash
#
# _refresh.sh — shared brain refresh, called by the git hooks.
# Keeps the local PGLite brain current: markdown notes (incremental, fast) and
# code (re-index, backgrounded). Idempotent and safe to run concurrently with the
# watcher — gbrain dedups by content hash. Never fails the git operation.
set -uo pipefail

REPO="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$REPO" ] && exit 0
export GBRAIN_HOME="$REPO/.gbrain"

# Nothing to do if the brain isn't initialized here (run .githooks/setup.sh once).
[ -f "$GBRAIN_HOME/config.json" ] || exit 0
command -v gbrain >/dev/null 2>&1 || exit 0

LOG="$GBRAIN_HOME/refresh.log"
ts() { date '+%Y-%m-%dT%H:%M:%S'; }

{
  echo "[$(ts)] refresh start ($(basename "$0"))"
  # 1) markdown notes — incremental via git diff, then backfill embeddings
  gbrain sync --repo "$REPO" && gbrain embed --stale
  echo "[$(ts)] markdown sync done"
} >> "$LOG" 2>&1

# 2) code — reindex in the background so the commit/checkout returns fast.
if gbrain reindex --help >/dev/null 2>&1; then
  ( GBRAIN_HOME="$GBRAIN_HOME" gbrain reindex --code --yes >> "$LOG" 2>&1 \
      && echo "[$(ts)] code reindex done" >> "$LOG" 2>&1 ) &
fi

exit 0
