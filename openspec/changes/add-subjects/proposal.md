# Proposal

## Why

EduTrack AI currently features placeholder sections for "Disciplinas" and static dashboard counters with no backend data integration for subjects. Students need a way to register, view, and manage their academic subjects (disciplinas) to track course progress, organize workload, and establish the baseline for task and study session management.

## What Changes

- Create a data model for academic subjects (`subjects`) containing attributes such as name, professor, semester/code, workload/credits, status (active/archived), and timestamps.
- Define backend CRUD endpoints (or mock/API handlers) for managing subjects per student/user.
- Implement the "Disciplinas" view in Streamlit (`app.py`) allowing students to view registered subjects, create new subjects, and view subject details.
- Update the "Dashboard" view in `app.py` to dynamically reflect the count of active subjects.

## Capabilities

### New Capabilities
- `subjects`: Academic subject management including creation, listing, updating, and status tracking for student courses.

### Modified Capabilities

## Impact

- **Database / Schema**: New table definition for subjects (`subjects.xs`).
- **APIs**: New endpoints for subjects listing and creation.
- **Frontend**: Streamlit application UI in `app.py` updated to support interactive subject creation and listing.
- **Dependencies**: Uses existing Streamlit and Python runtime libraries without new external dependencies.

