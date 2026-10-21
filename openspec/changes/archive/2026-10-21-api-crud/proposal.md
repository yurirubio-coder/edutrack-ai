## Why

Students need a way to manage their subjects and academic tasks in EduTrack AI through secure RESTful endpoints. To guarantee student privacy and data integrity, all operations must be strictly scoped to the authenticated user (`user_id`), preventing any user from accessing or modifying another student's data.

## What Changes

- Create CRUD endpoints (POST, GET, PATCH, DELETE) for `subjects` in XanoScript, enforcing user isolation with the authenticated user (`$auth.id`).
- Create CRUD endpoints (POST, GET, PATCH, DELETE) for `academic_tasks` in XanoScript, enforcing user isolation with the authenticated user (`$auth.id`).
- Enforce strict ownership validation on update (PATCH) and delete (DELETE) operations so students can only modify or remove their own records.
- Filter list queries (GET) by the authenticated user's ID.

## Capabilities

### New Capabilities
- `subjects`: CRUD endpoints (POST, GET, PATCH, DELETE) for student subjects with strict user data isolation.

### Modified Capabilities
- `academic-tasks`: CRUD endpoints (POST, GET, PATCH, DELETE) for student academic tasks with strict user data isolation.

## Impact

- New API endpoints defined under `api/`:
  - `POST /subjects`: Create a new subject for the authenticated user.
  - `GET /subjects`: List all subjects belonging to the authenticated user.
  - `PATCH /subjects/{id}`: Update a subject belonging to the authenticated user.
  - `DELETE /subjects/{id}`: Delete a subject belonging to the authenticated user.
  - `POST /academic_tasks`: Create a new academic task for the authenticated user.
  - `GET /academic_tasks`: List all academic tasks belonging to the authenticated user.
  - `PATCH /academic_tasks/{id}`: Update an academic task belonging to the authenticated user.
  - `DELETE /academic_tasks/{id}`: Delete an academic task belonging to the authenticated user.
- Authentication dependency: All endpoints require authenticated user context (`auth = "user"`).

