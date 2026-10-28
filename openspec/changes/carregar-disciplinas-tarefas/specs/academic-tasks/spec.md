# academic-tasks Specification

## Purpose
Provides synchronization between the Streamlit academic tasks management interface and the Xano backend endpoints.

## ADDED Requirements

### Requirement: Academic tasks screen integration
The system SHALL synchronize the tasks screen (`pages/2_Tarefas.py`) with Xano backend endpoints `GET /academic_tasks`, `POST /academic_tasks`, `PATCH /academic_tasks/{academic_task_id}`, and `DELETE /academic_tasks/{academic_task_id}` using the authenticated user session.

#### Scenario: Display and filter user academic tasks
- **WHEN** an authenticated student opens the tasks page
- **THEN** the system SHALL fetch tasks from `GET https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks` with the user Bearer token and render them according to search and status filters

#### Scenario: Create new academic task
- **WHEN** an authenticated student submits a new task form
- **THEN** the system SHALL send a POST request to `POST https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks` associating the task with the selected subject and user

#### Scenario: Update academic task status
- **WHEN** an authenticated student changes the completion status of a task
- **THEN** the system SHALL send a PATCH request to `PATCH https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}` with the updated status

#### Scenario: Delete academic task
- **WHEN** an authenticated student confirms deletion of a task
- **THEN** the system SHALL send a DELETE request to `DELETE https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}` and remove the task

