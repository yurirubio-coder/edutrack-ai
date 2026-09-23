# Design

## Context

EduTrack AI uses Streamlit (`app.py`) for the user interface and Xano for backend database tables and API endpoints (represented as `.xs` configuration files in `tables/` and `apis/`). Currently, the "Disciplinas" tab in `app.py` contains static text, and the Dashboard displays a hardcoded "0" for active disciplines.

## Goals / Non-Goals

**Goals:**
- Define the Xano table schema for academic subjects in `tables/` (`subjects.xs`).
- Implement a subjects data management service layer that communicates with Xano APIs while providing an in-memory session-state fallback for local testing and demos when API credentials are unset.
- Create an interactive user interface in Streamlit under "Disciplinas" for viewing, creating, and filtering subjects.
- Dynamically calculate and display the active subjects count on the Dashboard.

**Non-Goals:**
- Grade calculations, GPA tracking, or syllabus uploads (to be addressed in subsequent changes).
- Class timetable scheduling or calendar synchronization.
- Complex multi-role permissions for disciplines.

## Decisions

### 1. Subject Data Model
- **Decision**: Define a dedicated table schema (`subjects.xs`) with fields:
  - `id`: integer, primary key
  - `created_at`: timestamp
  - `user_id`: integer reference to `user`
  - `name`: text (required)
  - `code`: text (optional, e.g. "CC101")
  - `professor`: text (optional)
  - `workload_hours`: integer (optional)
  - `status`: enum `["active", "archived"]` (defaults to "active")
- **Rationale**: Keeps the model simple, structured, and compatible with Xano's relational conventions.
- **Alternatives considered**: Storing subjects inside a JSON array on the user record (rejected: less scalable and hard to index/query).

### 2. Service Layer with Session State Fallback
- **Decision**: Encapsulate subject CRUD operations in a service module or helper functions. If Xano API environment variables (`XANO_API_URL`, `XANO_API_KEY`) are present, perform HTTP requests; otherwise, persist to `st.session_state` with initial sample data.
- **Rationale**: Ensures the Streamlit application can be run immediately for development, testing, and grading without requiring a live remote Xano workspace setup, while keeping the production architecture intact.
- **Alternatives considered**: Requiring live Xano API connectivity (rejected: impedes local automated testing and grading).

### 3. UI Presentation in Streamlit
- **Decision**: Organize "Disciplinas" into:
  - Subject cards / summary metrics (Total, Active, Archived).
  - Form inside an expander (`st.expander("Cadastrar Nova Disciplina")`) to add new subjects.
  - Interactive list with status badge and actions (toggle status).
- **Rationale**: Follows Streamlit best practices and keeps the UI clean and responsive.

## Risks / Trade-offs

- **[Risk] State resets on Streamlit session reload**: Without a live backend, session state resets if the user refreshes the browser.
  - *Mitigation*: Provide sample seed data in session state so the UI always renders populated views out of the box, with clear indicators.
- **[Risk] Form double-submission**: Users accidentally submitting multiple times.
  - *Mitigation*: Use `st.form` with clear submission triggers and success notifications.

