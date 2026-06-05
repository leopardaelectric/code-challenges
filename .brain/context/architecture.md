# code-challenges — architecture

## Purpose

Public interview challenge repository. Candidates pick a challenge (e.g. Trip
Segmenter), implement it in any language/stack, and submit a public repo link
to their interviewer. No solution code lives in this repo — it only holds
challenge specs (READMEs) and contribution guidelines.

## Structure

```
code-challenges/
├── backend/
│   └── trip-segmenter/   # one backend challenge (spec in README.md)
├── docs/
├── AGENTS.md
├── CLAUDE.md
└── README.md
```

## Key design decisions

- **Specs only, no implementations.** The repo deliberately avoids any solution
  code to keep challenges language/stack-agnostic and to not bias candidates.
- **Category-based layout** (`backend/`, future `frontend/`, `full-stack/`).
  Challenges live under the appropriate category folder; each is a directory
  with its own `README.md` describing requirements, examples, and evaluation
  criteria.
- **Extensible.** Adding a new challenge means creating a subdirectory under the
  correct category with a README, then updating the root README's table.

## Challenge spec anatomy (Trip Segmenter)

| Aspect | Detail |
|---|---|
| Objective | Service that ingests sequential motorcycle pings and groups them into trips |
| Input | License plate, timestamp, coordinates, speed, odometer |
| Trip fields | Start/end timestamp, start/end coords, total distance, plate |
| Delivery | Public repo → interviewer email |

## Adding a challenge

1. Create `<category>/<name>/README.md` with spec, examples, evaluation criteria
2. Update root `README.md` table

## Boundaries

- No tests, CI, or deployment config (challenge specs are static markdown)
- No runtime code, dependency files, or build scripts
- No database schemas or infra manifests
