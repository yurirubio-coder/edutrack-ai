## Context

EduTrack AI uses Streamlit as its web interface and Xano as backend (via XanoScript). Endpoints for `academic_tasks` and `subjects` are located in API group `College` with canonical ID `ILKDtEV0` (`https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0`), requiring Bearer authentication (`$auth.id`). Session tokens are stored in `st.session_state["auth_token"]` upon login or registration. The frontend pages `pages/1 _Disciplinas.py` and `pages/2_Tarefas.py` require real-time integration with these endpoints to load and persist records.

## Goals / Non-Goals

**Goals:**
- Load subjects from `GET https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects` and create subjects via `POST https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects`.
- Load academic tasks from `GET https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks`.
- Create academic tasks via `POST https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks`.
- Update task completion status via `PATCH https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}`.
- Remove tasks via `DELETE https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}`.
- Authenticate requests using Bearer token from `st.session_state["auth_token"]` (with fallback to `EDUTRACK_AUTH_TOKEN`).
- Provide feedback and handle unauthenticated access gracefully.

**Non-Goals:**
- Modifying backend Xano database tables or `.xs` files (they are fully functional).
- Modifying user authentication logic or profile screens.
- Implementing unrequested batch operations or complex scheduling algorithms.

## Decisions

- **API Base URL Resolution**:
  - Read `EDUTRACK_API_BASE_URL` or `XANO_COLLEGE_BASE_URL` from `.env` or system environment, defaulting to `https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0`.
- **Authentication State**:
  - Read `st.session_state.get("auth_token")` or fallback environment variable.
  - If unauthenticated, render an informative alert prompting login on `pages/3_👤_Perfil.py`.
- **Disciplinas Screen (`pages/1 _Disciplinas.py`)**:
  - Tab "📋 Listar": Calls `GET /subjects` and displays data in an interactive table with record count.
  - Tab "➕ Nova Disciplina": Form submitting `name`, `code`, and `description` to `POST /subjects`.
- **Tarefas Screen (`pages/2_Tarefas.py`)**:
  - Loads subjects via `GET /subjects` to build an ID-to-name dictionary.
  - Loads tasks via `GET /academic_tasks` with client-side filtering by search query and status ("Todas", "Pendente", "Concluída").
  - Displays tasks inside expanders with a status checkbox triggering `PATCH /academic_tasks/{academic_task_id}` and a delete button triggering `DELETE /academic_tasks/{academic_task_id}`.
  - Tab "➕ Nova Tarefa": Form allowing creation with title, associated subject, optional due date, description, and initial status via `POST /academic_tasks`.

## Risks / Trade-offs

- **Risk**: User accesses pages without an active session token.
  - **Mitigation**: Prominently display a friendly warning guiding the student to authenticate via the Profile screen before loading API data.
- **Risk**: Network latency or endpoint communication errors.
  - **Mitigation**: Wrap all requests in try/except blocks and display actionable error messages via `st.error`.

