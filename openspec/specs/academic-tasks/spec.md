# academic-tasks Specification

## Purpose
Defines the database schema and storage structure for managing student academic tasks linked to subjects in EduTrack AI, and provides RESTful CRUD endpoints for students to manage academic tasks with strict user data isolation.

## Requirements

### Requirement: Academic tasks table schema
The system SHALL define and persist an `academic_tasks` table containing `title` (text), `description` (text), `due_date` (date), `status` (text), `subject_id` (reference to `subjects`), and `user_id` (reference to `user`).

#### Scenario: Academic task schema definition
- **WHEN** the `academic_tasks` table is inspected
- **THEN** it SHALL contain fields `title`, `description`, `due_date`, `status`, `subject_id`, and `user_id` with appropriate data types and foreign key relationships

### Requirement: Create academic task endpoint
The system SHALL provide a POST `/academic_tasks` endpoint that creates a new academic task record associated with the authenticated user (`user_id`).

#### Scenario: Student creates an academic task
- **WHEN** an authenticated student sends a POST request to `/academic_tasks` with task details (`title`, optional `description`, `due_date`, `status`, `subject_id`)
- **THEN** the system SHALL persist the task associated with the student's `user_id` and return the created record

### Requirement: List user academic tasks endpoint
The system SHALL provide a GET `/academic_tasks` endpoint that returns only the academic tasks belonging to the authenticated user (`user_id`).

#### Scenario: Student retrieves their tasks
- **WHEN** an authenticated student sends a GET request to `/academic_tasks`
- **THEN** the system SHALL return a list of academic tasks where `user_id` matches the authenticated student, excluding tasks belonging to other users

### Requirement: Update academic task endpoint
The system SHALL provide a PATCH `/academic_tasks/{id}` endpoint that updates an existing academic task only if it belongs to the authenticated user.

#### Scenario: Student updates their own task
- **WHEN** an authenticated student sends a PATCH request to `/academic_tasks/{id}` for a task they own
- **THEN** the system SHALL update the task fields and return the updated record

#### Scenario: Student attempts to update another user's task
- **WHEN** an authenticated student sends a PATCH request to `/academic_tasks/{id}` for a task owned by another user
- **THEN** the system SHALL reject the request with a not found error without modifying any data

### Requirement: Delete academic task endpoint
The system SHALL provide a DELETE `/academic_tasks/{id}` endpoint that deletes an existing academic task only if it belongs to the authenticated user.

#### Scenario: Student deletes their own task
- **WHEN** an authenticated student sends a DELETE request to `/academic_tasks/{id}` for a task they own
- **THEN** the system SHALL remove the task record and return confirmation

#### Scenario: Student attempts to delete another user's task
- **WHEN** an authenticated student sends a DELETE request to `/academic_tasks/{id}` for a task owned by another user
- **THEN** the system SHALL reject the request with a not found error without deleting the record
