# subjects Specification

## Purpose
Provides synchronization between the Streamlit subjects management interface and the Xano backend endpoints.

## ADDED Requirements

### Requirement: Subjects screen integration
The system SHALL synchronize the subjects screen (`pages/1 _Disciplinas.py`) with Xano backend endpoints `GET /subjects` and `POST /subjects` using the authenticated user session.

#### Scenario: Display user subjects
- **WHEN** an authenticated student opens the subjects page
- **THEN** the system SHALL fetch subjects from `GET https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects` using the user's Bearer token and display them

#### Scenario: Create new subject
- **WHEN** an authenticated student submits a new subject form
- **THEN** the system SHALL send a POST request to `POST https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects` and refresh the subjects list

