# activity-grades Specification

## Purpose
Allows teachers to record and persist student grades for specific academic activities in EduTrack AI.

## ADDED Requirements

### Requirement: Persist activity grades
The system SHALL store student activity grades in the `activity_grades` table associated with the authenticated user (`user_id`).

#### Scenario: Successfully record a grade
- **WHEN** teacher submits a valid grade for a student and activity
- **THEN** the system SHALL store the grade record with the associated `user_id` and return confirmation

### Requirement: Submit grade API
The system SHALL provide a POST `/activity_grades` endpoint to allow authenticated teachers to submit grades for student activities.

#### Scenario: Teacher posts a new activity grade
- **WHEN** an authenticated teacher sends a POST request to `/activity_grades` with valid activity, student, and grade data
- **THEN** the system SHALL create the grade entry and respond with the created record

