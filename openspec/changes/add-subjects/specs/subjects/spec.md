# Spec Delta

## Purpose

Enables students to manage academic subjects (disciplinas), track course details, and maintain an organized view of active and past coursework within EduTrack AI.

## ADDED Requirements

### Requirement: Subject Creation
The system SHALL allow users to create a new academic subject with required name and optional metadata including professor name, subject code, and academic term.

#### Scenario: Successfully create a new subject
- **WHEN** the user enters valid subject details including a name and submits the creation form
- **THEN** the system records the new subject and makes it immediately available in the subject list

#### Scenario: Validation on missing subject name
- **WHEN** the user attempts to submit a subject with an empty name
- **THEN** the system rejects the submission and displays a validation error prompt

### Requirement: Subject Listing
The system SHALL display all registered subjects belonging to the student, presenting key details such as subject name, instructor, and current status.

#### Scenario: View list of registered subjects
- **WHEN** the user opens the "Disciplinas" section
- **THEN** the system displays all enrolled subjects with their corresponding attributes

#### Scenario: Empty state display
- **WHEN** the user navigates to "Disciplinas" and no subjects have been created yet
- **THEN** the system displays an empty state notification inviting the student to register their first subject

### Requirement: Subject Status Management
The system SHALL allow users to set and toggle the status of a subject between active and archived.

#### Scenario: Toggle subject status
- **WHEN** the user updates the status of a subject
- **THEN** the system updates the subject record and updates its active state accordingly

### Requirement: Active Subjects Dashboard Metric
The system SHALL calculate the total count of active subjects and display it on the main dashboard.

#### Scenario: Dynamic metric display on dashboard
- **WHEN** the user views the "Dashboard" view
- **THEN** the system displays the "Disciplinas Ativas" counter matching the exact number of active subjects

