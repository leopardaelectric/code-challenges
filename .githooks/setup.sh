#!/usr/bin/env bash
#
# repo-brain setup — run ONCE per machine after this repo gains the repo-brain
# wiring (i.e. after merging the PR, or right after install).
#
# Builds the local gbrain knowledge layer for THIS repo:
#   - local PGLite brain at ./.gbrain   (gitignored; never leaves your machine)
#   - LOCAL embeddings via Ollama (no API key, no network egress)
#   - indexes the code (--strategy code) + the committed markdown in ./.brain
#   - activates the git hooks (core.hooksPath -> .githooks) so the brain stays
#     current on every commit / merge / checkout
#
# Idempotent: safe to re-run. Run from the repo root:  ./.githooks/setup.sh
set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"
cd "$REPO"
export GBRAIN_HOME="$REPO/.gbrain"
SOURCE_ID="$(cat "$REPO/.gbrain-source" 2>/dev/null || basename "$REPO")"

if ! command -v gbrain >/dev/null 2>&1; then
  echo "error: gbrain not found on PATH. Install it first:" >&2
  echo "  git clone https://github.com/garrytan/gbrain.git && cd gbrain && bun install && bun link" >&2
  exit 1
fi

# Embedding model: LOCAL / offline via Ollama (no API key, no network).
# Override with env vars if you run a different local model.
EMBED_MODEL="${BRAIN_EMBED_MODEL:-ollama:nomic-embed-text}"
EMBED_DIMS="${BRAIN_EMBED_DIMS:-768}"

# Preflight: a local Ollama-backed model needs Ollama running + the model pulled.
if [[ "$EMBED_MODEL" == ollama:* ]]; then
  OLLAMA_MODEL="${EMBED_MODEL#ollama:}"
  OLLAMA_URL="${OLLAMA_BASE_URL:-http://localhost:11434}"
  if ! curl -fsS "${OLLAMA_URL%/v1}/api/tags" >/dev/null 2>&1; then
    echo "error: Ollama not reachable at ${OLLAMA_URL%/v1}." >&2
    echo "  Install from https://ollama.ai, then:  ollama pull $OLLAMA_MODEL && ollama serve" >&2
    exit 1
  fi
  if ! curl -fsS "${OLLAMA_URL%/v1}/api/tags" 2>/dev/null | grep -q "\"$OLLAMA_MODEL"; then
    echo "==> pulling local embedding model: $OLLAMA_MODEL"
    ollama pull "$OLLAMA_MODEL" || { echo "error: 'ollama pull $OLLAMA_MODEL' failed" >&2; exit 1; }
  fi
fi

mkdir -p "$GBRAIN_HOME"
if [ -f "$GBRAIN_HOME/config.json" ]; then
  echo "==> brain already initialized at .gbrain (skipping init)"
else
  echo "==> gbrain init --pglite (embedding: $EMBED_MODEL / $EMBED_DIMS)"
  gbrain init --pglite --embedding-model "$EMBED_MODEL" --embedding-dimensions "$EMBED_DIMS"
fi

echo "==> registering code source ($SOURCE_ID)"
gbrain sources add "$SOURCE_ID" --path "$REPO" --strategy code 2>/dev/null \
  || echo "    (source already present, or 'sources add' flags differ on your gbrain version — see docs/repo-brain.md)"

echo "==> activating git hooks (core.hooksPath -> .githooks)"
git config core.hooksPath .githooks

echo "==> initial sync + embed"
gbrain sync --repo "$REPO" && gbrain embed --stale || true
if gbrain reindex --help >/dev/null 2>&1; then
  gbrain reindex --code --yes || true
fi

cat <<EOF

==> DONE. The brain is live and will refresh on every commit/merge/checkout.

Wire your agent to it (Claude Code, from the repo root):
  GBRAIN_HOME="$GBRAIN_HOME" claude mcp add brain_$SOURCE_ID -- gbrain serve

Optional always-on watcher for uncommitted edits:
  ./.githooks/brain-watch.sh
  # or as a launchd agent:
  SID=\$(cat .gbrain-source); REPO=\$(pwd)
  sed -e "s|__SOURCE_ID__|\$SID|g" -e "s|__REPO__|\$REPO|g" \\
      .githooks/launchd.plist.template > ~/Library/LaunchAgents/com.vammo.gbrain.\$SID.plist
  launchctl load ~/Library/LaunchAgents/com.vammo.gbrain.\$SID.plist

See docs/repo-brain.md for details.
EOF
