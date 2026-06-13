#!/usr/bin/env bash
#
# _refresh.sh — shared brain refresh, called by the git hooks.
# Keeps the local PGLite brain current. Runs fully in the background so the
# git operation returns immediately; gbrain dedups by content hash, so
# overlapping runs are safe. Never fails the git operation.
#
# ORDER + COMMAND CHOICE MATTER. Code goes through `sync --strategy code`
# (the only consumer of the sync bookmark); notes go through `gbrain import`
# (content-hash based, no bookmark, never deletes). A plain `gbrain sync`
# must NOT run here: its incremental pass treats changed code files as
# un-syncable, DELETES their pages, and advances the shared bookmark so the
# code sync that follows sees "Already up to date" and never re-imports them
# — every commit silently shrinks the brain (verified on gbrain 0.42.37).
set -uo pipefail

REPO="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$REPO" ] && exit 0
# GBRAIN_HOME is the parent dir; the brain lives at $GBRAIN_HOME/.gbrain/.
export GBRAIN_HOME="$REPO"

# Nothing to do if the brain isn't initialized here (run .githooks/setup.sh once).
[ -f "$GBRAIN_HOME/.gbrain/config.json" ] || exit 0
command -v gbrain >/dev/null 2>&1 || exit 0

LOG="$GBRAIN_HOME/.gbrain/refresh.log"
ts() { date '+%Y-%m-%dT%H:%M:%S'; }

(
  echo "[$(ts)] refresh start ($(basename "$0"))"
  # 1) code — incremental commit-to-commit sync (bookmark consumer)
  gbrain sync --strategy code --repo "$REPO" --no-pull --no-embed --yes
  # 2) notes (.brain/) — content-hash import; picks up the working tree as-is
  [ -d "$REPO/.brain" ] && gbrain import "$REPO/.brain" --no-embed
  # 3) embeddings for whatever 1+2 touched
  gbrain embed --stale
  echo "[$(ts)] refresh done"
) >> "$LOG" 2>&1 &

exit 0
