# student-performance-report Specification

## Purpose
Allows generating a PDF report containing student academic performance metrics (subjects, task completion, and progress) using a Python script, and downloading this report file via an authenticated Xano backend endpoint.

## ADDED Requirements

### Requirement: Generate student performance report in PDF
The system SHALL provide a Python script located at `scripts/generate_performance_report.py` that aggregates academic performance data for an authenticated student and generates a formatted PDF document.

#### Scenario: Successfully generate PDF report for a student
- **WHEN** the script is executed for an authenticated student
- **THEN** the system SHALL compile the student's subjects, tasks, and completion metrics into a valid PDF document

#### Scenario: Generate PDF report for student with no records
- **WHEN** the script is executed for a student with no registered subjects or tasks
- **THEN** the system SHALL output a valid PDF document displaying zero records and 0.0% completion without throwing an unhandled exception

### Requirement: Xano endpoint for downloading report file
The system SHALL provide a GET `/student_performance_report` endpoint in the `College` API group allowing authenticated students to download their performance report PDF file.

#### Scenario: Authenticated student downloads performance report
- **WHEN** an authenticated student sends a GET request to `/student_performance_report`
- **THEN** the system SHALL retrieve and return the PDF report file associated with the authenticated user (`user_id == $auth.id`)

#### Scenario: Unauthenticated request to download report
- **WHEN** an unauthenticated request is sent to `/student_performance_report`
- **THEN** the system SHALL reject the request with an authentication error

### Requirement: Frontend interface for report download
The system SHALL provide a frontend interface in the Streamlit application allowing authenticated students to view performance metrics and download their PDF performance report.

#### Scenario: Authenticated student downloads report via frontend
- **WHEN** an authenticated student accesses the reports page (`pages/3_Files.py`) or tasks export and clicks to download the report
- **THEN** the system SHALL generate and trigger download of the student performance PDF file

#### Scenario: Unauthenticated student accesses reports page
- **WHEN** an unauthenticated student navigates to `pages/3_Files.py`
- **THEN** the system SHALL display an authentication warning and block access to report downloads
