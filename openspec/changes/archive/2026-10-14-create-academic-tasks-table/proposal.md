## Why

Students need a structured way to register and track their academic obligations (assignments, exams, coursework) linked to each academic subject. Currently, EduTrack AI lacks a dedicated table to persist academic tasks.

## What Changes

- Create `academic_tasks` table in the database schema to store academic tasks with fields:
  - `title` (text)
  - `description` (text)
  - `due_date` (date)
  - `status` (text)
  - `subject_id` (reference to `subjects`)
  - `user_id` (reference to `user` for student data isolation)

## Capabilities

### New Capabilities
- `academic-tasks`: Data persistence and schema structure for student academic tasks.

### Modified Capabilities

## Impact

- New table `academic_tasks` defined in XanoScript (`table/academic_tasks.xs`).
- Foreign key relationship to `subjects` table via `subject_id`.
- Foreign key relationship to `user` table via `user_id`.

