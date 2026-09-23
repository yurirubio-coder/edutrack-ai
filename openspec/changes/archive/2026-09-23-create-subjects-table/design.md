# Design

## Context

The user requested defining the `subjects` table schema in Xano format based on the rules specified in `AGENTS.md`. The table must contain `id` (auto), `name` (text), `teacher` (text), `hours` (int), and `user_id` (foreign key to `user`).

## Goals / Non-Goals

**Goals:**
- Provide the declarative `.xs` schema file in `tables/subjects.xs` with proper column types, visibility attributes, filters, and indexes.
- Ensure strict adherence to `AGENTS.md` scope boundaries.

**Non-Goals:**
- Generating API CRUD endpoints (explicitly excluded by `AGENTS.md` unless requested).
- Generating frontend UI components (explicitly excluded by `AGENTS.md`).
- Generating unit/integration test suites (explicitly excluded by `AGENTS.md`).
- Attempting push or sync to Xano instance (developer responsibility).

## Decisions

### 1. Table Schema Structure in `.xs`
- **Fields**:
  - `id`: integer primary key.
  - `created_at`: timestamp with default `now` and private visibility.
  - `name`: text with `filters=trim`.
  - `teacher`: text with `filters=trim`.
  - `hours`: integer.
  - `user_id`: integer with reference `table = "user"`.
- **Indexes**:
  - Primary index on `id`.
  - Btree index on `created_at` descending.
  - Btree index on `user_id` ascending.

## Risks / Trade-offs

- **[Risk] Schema synchronization**: Changes in local `.xs` files are not automatically deployed to remote Xano.
  - *Mitigation*: User performs manual push/sync via Xano tools as specified in `AGENTS.md`.

