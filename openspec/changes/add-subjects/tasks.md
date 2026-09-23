# Tasks

## 1. Schema & Backend Foundation

- [x] 1.1 Create Xano table schema file `tables/subjects.xs` with fields for id, user_id, name, code, professor, workload, and status, and verify file format matches project conventions
- [x] 1.2 Implement subject management service layer with support for session state persistence and Xano API client integration, verifying data operations (list, create, update status)

## 2. Streamlit UI Implementation

- [x] 2.1 Build subject registration form in `app.py` under "Disciplinas" with validation for required name field and verify new subjects can be added
- [x] 2.2 Build subjects listing view in `app.py` with subject cards, professor/code details, and empty state guidance when no subjects exist
- [x] 2.3 Add status management control (active vs archived toggle) for each subject and verify status changes persist in state

## 3. Dashboard Integration & Verification

- [x] 3.1 Connect Dashboard "Disciplinas Ativas" metric to dynamically count active subjects from the service layer and verify count updates when subjects are added or archived
- [x] 3.2 Run and verify Streamlit application end-to-end to ensure navigation, creation, listing, and metrics operate cleanly without errors

