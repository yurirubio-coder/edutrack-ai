# Proposal

## Why

EduTrack AI requires a structured data schema for subjects (disciplinas) in the Xano backend to persist course information linked to authenticated users. Defining the schema in `.xs` format establishes the authoritative database definition according to project specifications.

## What Changes

- Define the table schema for `subjects` in `tables/subjects.xs` with the exact fields requested:
  - `id`: integer, auto-incrementing primary key
  - `name`: text, subject title
  - `teacher`: text, instructor name
  - `hours`: integer, workload hours
  - `user_id`: integer, foreign key referencing the `user` authentication table
  - `created_at`: timestamp with default `now`
- Adhere strictly to the task scope defined in `AGENTS.md` (no automatic CRUD APIs, tests, or frontend additions).

## Capabilities

### New Capabilities
- `subjects-table`: Schema definition for the `subjects` table in Xano conforming to the fields specified in the request.

### Modified Capabilities

## Impact

- **Database / Schema**: Creates or updates `tables/subjects.xs` in Xano table format.
- **Scope Limit**: Excludes API CRUD, tests, and frontend integration per `AGENTS.md`.

