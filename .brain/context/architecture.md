# Architecture

Public, documentation-only repository holding Vammo's technical-interview coding challenges (challenge specs, not solutions).

## Purpose

This repo is the source of the take-home / technical challenges Vammo uses when
interviewing software engineering candidates. It ships **challenge prompts**
(requirements, evaluation criteria, delivery instructions) — candidates implement
their solutions in their own separate public repositories and send the link back
to their interviewer. There is no application source, no runtime, and no build
here; everything is Markdown.

## Tech stack

None in the conventional sense. The repo contains only Markdown documentation.
There is no manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`,
`Makefile`, etc.), no dependencies, no CI, and no build tooling. Candidates are
explicitly free to use **any** language, framework, database, and architecture
for their solutions.

## Layout

- `README.md` — landing page: states the purpose, lists available challenges in a
  table (by category: Backend / Frontend / Full-Stack), and documents general
  rules, evaluation criteria, and submission instructions. Frontend and
  Full-Stack sections are currently placeholders ("Coming soon...").
- `backend/` — backend challenges, one folder per challenge.
  - `backend/trip-segmenter/README.md` — the only challenge currently published.

## Challenges

### backend/trip-segmenter (Medium, backend logic)

Spec for a backend service that ingests sequential **motorcycle GPS pings** and
groups them into **trips** based on movement and idleness.

- Each ping carries: license plate, UNIX timestamp, coordinates, speed, odometer
  reading. Pings arrive in order per motorcycle.
- Candidate decides the trip logic (start/end conditions, idle threshold,
  distance computation via odometer/GPS/both, whether to store raw pings or only
  summaries). Every trip must include at least: start/end timestamp, start/end
  coordinates, total distance (odometer-based), and the motorcycle license plate.
- Required features: (1) ping ingestion (any method — HTTP, queue, file importer,
  generator), (2) paginated trip listing, (3) single-trip detail fetch.
- Optional bonuses: interactive interface (CLI/web/Postman), event-driven
  ingestion (Kafka/NATS/RabbitMQ/SQS/file watcher/webhooks), trip visualization
  (map/polyline/ASCII).

## Conventions (non-obvious)

- This is a **public** repository — content is candidate-facing. Do not commit
  reference solutions, internal evaluation rubrics beyond what's already public,
  or any internal Vammo links/credentials.
- Adding a new challenge: create a folder under the right category
  (`backend/`, `frontend/`, etc.) with its own comprehensive `README.md`
  (requirements, examples, evaluation criteria), then add a row to the challenge
  table in the root `README.md`.
- Delivery is decentralized: candidates push solutions to their own public repos
  and email the link to their interviewer — nothing candidate-authored lands in
  this repo.
