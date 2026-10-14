## Context

EduTrack AI manages academic activities and student records. Currently, teachers need the capability to submit grades for specific activities assigned to students.

## Goals / Non-Goals

**Goals:**
- Provide database schema (`activity_grades`) to store student activity grades linked to the authenticated user.
- Provide a REST endpoint (`POST /activity_grades`) to record student grades for specific activities.

**Non-Goals:**
- Querying, listing, or filtering grades (`GET` endpoints are out of scope as they were not explicitly requested).
- Editing or deleting existing grades (`PATCH`/`DELETE` endpoints are out of scope).

## Decisions

- **Table schema**: Create `activity_grades` table storing `student_id`, `activity_id`, `grade`, and timestamps, linked with `user_id` for ownership/security.
- **Single creation endpoint**: `POST /activity_grades` accepts grading payload, validates inputs, and inserts record associated with `user_id`.

## Risks / Trade-offs

- [Risk: Missing grade lookups] → Mitigation: Can be proposed in a future change if query/listing requirements are requested.

