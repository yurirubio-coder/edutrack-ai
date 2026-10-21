## Context

EduTrack AI is an academic management application using Xano as its backend (defined via XanoScript) and Streamlit as frontend. The platform requires endpoints for students to manage both academic subjects and tasks. Security and tenant isolation require that each student only access, modify, or delete their own data.

## Goals / Non-Goals

**Goals:**
- Implement RESTful CRUD endpoints for `subjects`:
  - `POST /subjects`: Creates a subject record associated with `$auth.id`.
  - `GET /subjects`: Retrieves subjects where `user_id == $auth.id`.
  - `PATCH /subjects/{id}`: Updates subject identified by `{id}` only if `user_id == $auth.id`.
  - `DELETE /subjects/{id}`: Deletes subject identified by `{id}` only if `user_id == $auth.id`.
- Implement RESTful CRUD endpoints for `academic_tasks`:
  - `POST /academic_tasks`: Creates a task record associated with `$auth.id` and optional `subject_id`.
  - `GET /academic_tasks`: Retrieves tasks where `user_id == $auth.id`.
  - `PATCH /academic_tasks/{id}`: Updates task identified by `{id}` only if `user_id == $auth.id`.
  - `DELETE /academic_tasks/{id}`: Deletes task identified by `{id}` only if `user_id == $auth.id`.
- Enforce `auth = "user"` on all endpoints and validate ownership using preconditions.

**Non-Goals:**
- Creating Streamlit frontend pages or UI elements (not requested).
- Modifying underlying table schemas beyond existing field requirements (not requested).
- Creating unrequested batch or administrative query endpoints (not requested).

## Decisions

- **Authentication & Multi-tenancy**:
  - All endpoints use `auth = "user"`, extracting authenticated user id from `$auth.id`.
  - On `POST`: `user_id` is set to `$auth.id` directly to prevent identity spoofing.
  - On `GET`: Filter records with `user_id = $auth.id`.
  - On `PATCH` and `DELETE`: Records are fetched and validated matching both `id = $input.id` and `user_id = $auth.id`. If no matching record is found, return a `notfound` precondition error, preventing unauthorized modifications.
- **RESTful Endpoint Organization**:
  - Follow XanoScript query and API group structure:
    - `POST /subjects`
    - `GET /subjects`
    - `PATCH /subjects/{id}`
    - `DELETE /subjects/{id}`
    - `POST /academic_tasks`
    - `GET /academic_tasks`
    - `PATCH /academic_tasks/{id}`
    - `DELETE /academic_tasks/{id}`

## Risks / Trade-offs

- **Risk**: Unauthorized access or ID tampering by modifying the `{id}` parameter in URL paths.
  - **Mitigation**: Every mutation explicitly filters on both `id` and `user_id == $auth.id`. A request targeting another user's ID will trigger a 404/not found precondition error without revealing information.

