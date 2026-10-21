# academic-progress Specification

## Purpose
Defines the specification for calculating academic progress of subjects based on their associated academic tasks in EduTrack AI, consuming existing CRUD endpoints and returning structured JSON metrics.

## ADDED Requirements

### Requirement: Progress calculation script
The system SHALL provide a Python script located at `scripts/calculate_progress.py` that calculates the progress percentage for a subject based on its academic tasks and outputs the result as a JSON object.

#### Scenario: Calculate progress with completed and pending tasks
- **WHEN** the script calculates progress for a subject with total tasks and completed tasks
- **THEN** the system SHALL calculate `progress_percentage` as `(completed_tasks / total_tasks) * 100` and return a JSON payload with `subject_id`, `total_tasks`, `completed_tasks`, `pending_tasks`, and `progress_percentage`

#### Scenario: Calculate progress when a subject has zero tasks
- **WHEN** the script calculates progress for a subject with zero total tasks
- **THEN** the system SHALL set `progress_percentage` to `0.0` without raising an arithmetic error and return the JSON payload

### Requirement: Data retrieval via CRUD endpoints
The system SHALL retrieve subject and academic task records by querying the existing CRUD endpoints.

#### Scenario: Fetch tasks for subject progress calculation
- **WHEN** the script is executed for a given subject
- **THEN** the system SHALL query the CRUD endpoints to retrieve the tasks associated with that subject

