# code-challenges — architecture

A public repository of Vammo technical interview challenges for software engineering candidates.

## Purpose

Hosts self-contained coding challenges used in Vammo's hiring process. Each challenge is a standalone spec — no shared runtime, no application code in this repo. Candidates implement their own solution externally and submit via a public GitHub link.

## Tech stack

None in the repo itself. Challenges are language- and stack-agnostic by design; candidates choose their own tech.

## Structure

```
backend/
  trip-segmenter/   — challenge spec (README.md only)
docs/
  repo-brain.md     — repo-brain setup guide
README.md           — index of all challenges + submission guidelines
```

## Challenges

| Path | Name | Difficulty | Domain |
|---|---|---|---|
| `backend/trip-segmenter/` | Trip Segmenter | Medium | Backend logic |

**Trip Segmenter** — candidates build a backend service that ingests sequential motorcycle GPS pings (license plate, UNIX timestamp, coordinates, speed, odometer) and groups them into logical trips. Trip boundary logic, storage strategy, and ingestion method are intentionally open-ended. Core deliverables: paginated trip listing + single trip detail with license plate.

## Conventions

- Each challenge lives in `<category>/<challenge-name>/README.md`.
- No application code committed; specs only.
- New challenges: create folder under appropriate category, write comprehensive README, update root README table.
- Candidates submit by pushing their solution to a public repo and sharing the link with the interviewer.
