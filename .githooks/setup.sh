#!/usr/bin/env bash
#
# repo-brain setup — run ONCE per machine after this repo gains the repo-brain
# wiring (i.e. after merging the PR, or right after install).
#
# Builds the local gbrain knowledge layer for THIS repo:
#   - local PGLite brain at ./.gbrain   (gitignored; never leaves your machine)
#   - LOCAL embeddings via Ollama (no API key, no network egress)
#   - indexes the code (--strategy code) + the committed markdown in ./.brain
#     into the brain's DEFAULT source (single source; queries + `gbrain serve`
#     find code AND notes without per-source routing)
#   - activates the git hooks (core.hooksPath -> .githooks) so the brain stays
#     current on every commit / merge / checkout
#
# Idempotent: safe to re-run. Run from the repo root:  ./.githooks/setup.sh
set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"
cd "$REPO"
# GBRAIN_HOME is the PARENT dir; gbrain creates/reads the brain at
# $GBRAIN_HOME/.gbrain/. Point it at the repo root so the brain lives at
# $REPO/.gbrain (matching the /.gbrain/ gitignore). Using $REPO/.gbrain here
# would double-nest it as $REPO/.gbrain/.gbrain.
export GBRAIN_HOME="$REPO"
# Logical name for this repo's brain — used only for the MCP server name
# (brain_<id>). Derived from the repo basename; there is no .gbrain-source pin
# (a pin to a named source breaks the default-source model: `gbrain import`
# always writes to the default source, and queries pinned to a missing source
# error out with "Source not found").
SOURCE_ID="$(basename "$REPO" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')"

if ! command -v gbrain >/dev/null 2>&1; then
  echo "error: gbrain not found on PATH. Install it first:" >&2
  echo "  git clone https://github.com/garrytan/gbrain.git && cd gbrain && bun install && bun link" >&2
  exit 1
fi

# Embedding model: LOCAL / offline via Ollama (no API key, no network).
# Override with env vars if you run a different local model.
EMBED_MODEL="${BRAIN_EMBED_MODEL:-ollama:nomic-embed-text}"
EMBED_DIMS="${BRAIN_EMBED_DIMS:-768}"

# Preflight: a local Ollama-backed model needs Ollama running, the model pulled,
# AND a working inference runner. NOTE: `brew install ollama` (the Homebrew
# *formula*) ships NO llama-server runner — its daemon answers /api/tags but
# 500s on inference ("llama-server binary not found"). Use the official app
# (`brew install --cask ollama` / https://ollama.com), which bundles the runner.
if [[ "$EMBED_MODEL" == ollama:* ]]; then
  OLLAMA_MODEL="${EMBED_MODEL#ollama:}"
  OLLAMA_URL="${OLLAMA_BASE_URL:-http://localhost:11434}"
  BASE="${OLLAMA_URL%/v1}"

  # 1) daemon reachable?
  if ! curl -fsS "$BASE/api/tags" >/dev/null 2>&1; then
    echo "error: Ollama not reachable at $BASE." >&2
    echo "  Install the OFFICIAL app (the Homebrew formula ships no inference runner):" >&2
    echo "    brew install --cask ollama      # or download from https://ollama.com" >&2
    echo "  then start it:  open -a Ollama     (or 'ollama serve')" >&2
    exit 1
  fi

  # 2) model pulled?
  if ! curl -fsS "$BASE/api/tags" 2>/dev/null | grep -q "\"$OLLAMA_MODEL"; then
    echo "==> pulling local embedding model: $OLLAMA_MODEL"
    ollama pull "$OLLAMA_MODEL" || { echo "error: 'ollama pull $OLLAMA_MODEL' failed" >&2; exit 1; }
  fi

  # 3) can it ACTUALLY embed? The formula's daemon passes (1) and (2) but fails
  #    here — catch the silent failure mode now, with a fix hint.
  probe="$(curl -fsS "$BASE/api/embed" -d "{\"model\":\"$OLLAMA_MODEL\",\"input\":\"ping\"}" 2>/dev/null || true)"
  if ! printf '%s' "$probe" | grep -q '"embeddings"'; then
    echo "error: Ollama is up but cannot run embeddings (no inference runner)." >&2
    echo "  The Homebrew formula ('brew install ollama') bundles no llama-server runner;" >&2
    echo "  embeddings fail with 'llama-server binary not found'. Switch to the app:" >&2
    echo "    brew uninstall ollama 2>/dev/null; brew install --cask ollama" >&2
    echo "    open -a Ollama        # then re-run this script" >&2
    exit 1
  fi
fi

if [ -f "$GBRAIN_HOME/.gbrain/config.json" ]; then
  echo "==> brain already initialized at .gbrain (skipping init)"
else
  echo "==> gbrain init --pglite (embedding: $EMBED_MODEL / $EMBED_DIMS)"
  gbrain init --pglite --embedding-model "$EMBED_MODEL" --embedding-dimensions "$EMBED_DIMS"
fi

# Index everything into the DEFAULT source. Code goes through `sync
# --strategy code` (bookmark-based); notes go through `gbrain import`
# (content-hash, no bookmark) — this pair never deletes each other's pages.
# Never use a plain `gbrain sync` against this repo: its incremental pass
# deletes code pages as "un-syncable" (see _refresh.sh).
# NOTE: `gbrain sync --strategy code` walks the filesystem and does NOT honor
# .gitignore — it will index build output (dist/, build/, coverage/) if present.
# A fresh clone has none of these; if yours is built, `rm -rf dist` first or
# delete the dist-* pages afterward (see docs/repo-brain.md).
echo "==> indexing code (--strategy code) into the default source"
gbrain sync --strategy code --repo "$REPO" --no-pull --no-embed --yes

if [ -d "$REPO/.brain" ]; then
  echo "==> importing committed markdown notes (.brain/)"
  gbrain import "$REPO/.brain" --no-embed
fi

echo "==> embedding (local Ollama)"
gbrain embed --stale

echo "==> activating git hooks (core.hooksPath -> .githooks)"
git config core.hooksPath .githooks

cat <<EOF

==> DONE. The brain is live and will refresh on every commit/merge/checkout.

Wire your agent to it (Claude Code, from the repo root). Pass GBRAIN_HOME via
--env so it persists in the MCP server config (a command-prefix env var is NOT
captured by 'claude mcp add'):
  claude mcp add brain_$SOURCE_ID --env GBRAIN_HOME="$GBRAIN_HOME" -- gbrain serve

Sanity check:
  GBRAIN_HOME="$GBRAIN_HOME" gbrain stats
  GBRAIN_HOME="$GBRAIN_HOME" gbrain query "what is this repo"

Optional always-on watcher for uncommitted edits:
  ./.githooks/brain-watch.sh
  # or as a launchd agent:
  REPO="\$(pwd)"; SID="\$(basename "\$REPO" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')"
  sed -e "s|__SOURCE_ID__|\$SID|g" -e "s|__REPO__|\$REPO|g" \\
      .githooks/launchd.plist.template > ~/Library/LaunchAgents/com.vammo.gbrain.\$SID.plist
  launchctl load ~/Library/LaunchAgents/com.vammo.gbrain.\$SID.plist

See docs/repo-brain.md for details.
EOF
