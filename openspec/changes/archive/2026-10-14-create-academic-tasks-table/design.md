## Context

EduTrack AI allows students to manage their academic routines. Currently, students need to track their obligations (assignments, tests, and coursework) linked to specific subjects.

## Goals / Non-Goals

**Goals:**
- Define the XanoScript schema for the `academic_tasks` table.
- Include all fields requested by user: `title` (text), `description` (text), `due_date` (date), `status` (text), `subject_id` (reference to `subjects`).
- Include `user_id` (reference to `user`) to ensure student data isolation and ownership per EduTrack AI schema rules.

**Non-Goals:**
- Creating CRUD API endpoints (`GET`, `POST`, `PATCH`, `DELETE`) for tasks (not requested by user).
- Frontend/Streamlit interfaces (not requested by user).

## Decisions

- **Table schema design**:
  - `id`: Primary key (int)
  - `created_at`: Creation timestamp (timestamp?=now)
  - `title`: Task title (text filters=trim)
  - `description`: Task details (text? filters=trim)
  - `due_date`: Deadline date (date?)
  - `status`: Task status such as "pending", "in_progress", "completed" (text? filters=trim)
  - `subject_id`: Foreign key pointing to `subjects` table (`int subject_id? { table = "subjects" }`)
  - `user_id`: Foreign key pointing to `user` table (`int user_id? { table = "user" }`)
- **Indexes**:
  - Primary index on `id`.
  - Secondary btree index on `user_id` and `subject_id` for efficient user-scoped queries.

## Risks / Trade-offs

- [Risk: `subjects` table existence in target database] → Mitigation: If `subjects` is created in a separate migration/branch, foreign key reference can link cleanly once applied.

