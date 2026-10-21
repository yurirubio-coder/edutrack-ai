## Context

EduTrack AI manages student subjects and academic tasks with CRUD APIs defined in XanoScript (e.g., `GET /subjects`, `GET /academic_tasks`). To provide insights into student progress, a standalone Python utility script is required at `scripts/calculate_progress.py`. The script must compute completion percentage for a subject from its tasks and output structured JSON.

## Goals / Non-Goals

**Goals:**
- Implement `scripts/calculate_progress.py` in Python.
- Retrieve tasks for a given subject using existing CRUD endpoints.
- Calculate progress metrics:
  - `total_tasks`: Count of tasks linked to the subject.
  - `completed_tasks`: Count of tasks marked as completed.
  - `progress_percentage`: Ratio `(completed_tasks / total_tasks) * 100`.
- Output the calculation as a structured JSON object.
- Properly handle zero-task scenarios (`0.0%` progress) without division by zero.

**Non-Goals:**
- Creating new backend API endpoints or modifying Xano database tables.
- Building Streamlit UI components or dashboard widgets in this change.
- Deploying or syncing changes to Xano.

## Decisions

- **HTTP Client**: Use standard Python `urllib.request` or `requests` to consume the existing CRUD endpoints (`GET /academic_tasks` and `GET /subjects`).
- **Calculation Formula**:
  - `total_tasks = len(tasks)`
  - If `total_tasks == 0`, `progress_percentage = 0.0`.
  - Else, `progress_percentage = round((completed_tasks / total_tasks) * 100, 2)`.
- **Status Identification**: Consider a task completed if its `status` matches `"completed"` or `"concluida"` (case-insensitive).
- **JSON Output Schema**:
  ```json
  {
    "subject_id": 1,
    "total_tasks": 5,
    "completed_tasks": 3,
    "pending_tasks": 2,
    "progress_percentage": 60.0
  }
  ```

## Risks / Trade-offs

- **Risk**: A subject may have no tasks, which could lead to a division-by-zero error if unhandled.
  - **Mitigation**: Guard clause checks if `total_tasks == 0` and returns `0.0` for `progress_percentage`.
- **Risk**: Task status casing or naming inconsistencies (e.g. `completed` vs `Completed`).
  - **Mitigation**: Normalize status strings to lowercase and strip whitespace during evaluation.

