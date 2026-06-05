# .brain — repo knowledge layer

Markdown here is the **source of truth** for this repo's brain. It is committed
to git and indexed into the local gbrain (PGLite) on every commit, so knowledge
compounds over time and agents can query it.

Layout:
- `decisions/`  — architectural / product decisions (one file per decision)
- `context/`    — durable context: how things work, gotchas, glossary
- `learnings/`  — things discovered while building (postmortems, debugging notes)

Conventions:
- One topic per file. Descriptive slugs: `decisions/2026-06-some-decision.md`.
- Lead each file with a one-line summary. Agents read the first lines first.
- Append, don't overwrite — the point is to accumulate.

NOTE: `README.md`, `index.md`, `schema.md`, `log.md` are treated as meta files by
gbrain sync and are NOT indexed. Put real content in other filenames.

Setup / how it works: see [docs/repo-brain.md](../docs/repo-brain.md).
