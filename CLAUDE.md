
<!-- repo-brain:start -->
## Repo brain (knowledge layer) — brain-first

This repo has a local gbrain knowledge layer (PGLite, on each developer's
machine, local Ollama embeddings). It indexes the code and the committed markdown
in `.brain/`, and stays current automatically via git hooks. The MCP server
`brain_<source>` (command `gbrain serve`, `GBRAIN_HOME=./.gbrain`) exposes it.

**Before reaching for an external API, web search, or re-reading large parts of
the codebase, query the brain first.**

Lookup order for any question about this repo (how something works, why a
decision was made, where a symbol lives, prior debugging):

1. `query` — hybrid semantic + keyword search with synthesis and citations. Use first for "how/why/what".
2. `search` — fast keyword lookup when you know the term.
3. Code-aware tools — `code_def`, `code_callers`, `code_callees`, `code_refs`, `traverse_graph` — for "who calls X", "where is Y defined", call graphs.
4. `get_page` / `list_pages` / `get_backlinks` — read a specific note and follow links.

Writing back (this is how the brain compounds — do it):

- When you make or learn something durable — a decision, a non-obvious gotcha, a
  fix and its root cause — write it as a markdown file under `.brain/`
  (`decisions/`, `context/`, or `learnings/`) or via the `put_page` tool.
- One topic per file, descriptive slug, lead with a one-line summary.
- Append, don't overwrite. The value is accumulation.
- Committed markdown in `.brain/` is the source of truth; it re-indexes on every
  commit. Don't put real content in `README.md`/`index.md`/`schema.md`/`log.md`
  (gbrain treats those as meta and skips them).

Scope: this brain is THIS repo only. Don't assume it knows about other repos or
the shared team brain.

Setup (one-time, per machine): run `./.githooks/setup.sh`. Details in
[docs/repo-brain.md](docs/repo-brain.md).
<!-- repo-brain:end -->
