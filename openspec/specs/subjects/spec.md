# subjects Specification

## Purpose
Provides RESTful CRUD endpoints for students to manage academic subjects with strict user data isolation in EduTrack AI.

## Requirements

### Requirement: Create subject endpoint
The system SHALL provide a POST `/subjects` endpoint that creates a new subject record linked to the authenticated user (`user_id`).

#### Scenario: Student creates a new subject
- **WHEN** an authenticated student sends a POST request to `/subjects` with valid subject data
- **THEN** the system SHALL create the subject associated with the student's `user_id` and return the created record

### Requirement: List user subjects endpoint
The system SHALL provide a GET `/subjects` endpoint that returns only the subjects belonging to the authenticated user (`user_id`).

#### Scenario: Student lists their subjects
- **WHEN** an authenticated student sends a GET request to `/subjects`
- **THEN** the system SHALL return a list of subjects where `user_id` matches the authenticated student, excluding subjects of other users

### Requirement: Update subject endpoint
The system SHALL provide a PATCH `/subjects/{id}` endpoint that updates an existing subject record only if it belongs to the authenticated user.

#### Scenario: Student updates their own subject
- **WHEN** an authenticated student sends a PATCH request to `/subjects/{id}` for a subject they own with updated data
- **THEN** the system SHALL update the subject and return the updated record

#### Scenario: Student attempts to update another user's subject
- **WHEN** an authenticated student sends a PATCH request to `/subjects/{id}` for a subject owned by another user
- **THEN** the system SHALL reject the request with a not found error without modifying any data

### Requirement: Delete subject endpoint
The system SHALL provide a DELETE `/subjects/{id}` endpoint that deletes an existing subject record only if it belongs to the authenticated user.

#### Scenario: Student deletes their own subject
- **WHEN** an authenticated student sends a DELETE request to `/subjects/{id}` for a subject they own
- **THEN** the system SHALL remove the subject record and return confirmation

#### Scenario: Student attempts to delete another user's subject
- **WHEN** an authenticated student sends a DELETE request to `/subjects/{id}` for a subject owned by another user
- **THEN** the system SHALL reject the request with a not found error without deleting the record

