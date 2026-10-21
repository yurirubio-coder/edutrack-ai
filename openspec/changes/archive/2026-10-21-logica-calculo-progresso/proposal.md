## Why

Students need clear visibility into their academic progress for each subject in EduTrack AI. Currently, while subjects and academic tasks can be managed via CRUD endpoints, there is no automated logic or script to calculate the percentage of completed tasks for a given subject and return structured metrics.

## What Changes

- Create a Python script in `scripts/calculate_progress.py`.
- Implement logic to fetch subject and academic task data using the existing CRUD endpoints (`GET /subjects` and `GET /academic_tasks`).
- Calculate the progress percentage based on completed tasks versus total tasks (`(completed / total) * 100`).
- Handle edge cases gracefully (e.g., zero total tasks resulting in 0.0% progress).
- Return the calculated progress information as a JSON object.

## Capabilities

### New Capabilities
- `academic-progress`: Calculation and JSON reporting of subject progress percentage based on task completion status fetched from CRUD endpoints.

### Modified Capabilities

## Impact

- New script: `scripts/calculate_progress.py`.
- Integrates with existing REST CRUD endpoints (`GET /academic_tasks` and `GET /subjects`).
- No changes to database schemas or Xano backend endpoints.
- No changes to UI components.

