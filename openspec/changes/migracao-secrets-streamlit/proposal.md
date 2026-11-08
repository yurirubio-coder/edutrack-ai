## Why

Currently, the Streamlit frontend pages (`pages/3_👤_Perfil.py`, `pages/1 _Disciplinas.py`, `pages/2_Tarefas.py`, and `pages/3_Files.py`) load configuration values such as `XANO_AUTH_BASE_URL`, `XANO_COLLEGE_BASE_URL`, and `EDUTRACK_AUTH_TOKEN` by reading and parsing a local `.env` file manually from the filesystem root. This approach duplicates file reading logic, creates maintenance overhead, and does not align with Streamlit's native configuration and secrets mechanism (`st.secrets` backed by `.streamlit/secrets.toml`). Migrating to `st.secrets` standardizes configuration access across all pages, provides seamless fallback to system environment variables, and adheres to Streamlit recommended practices.

## What Changes

- Format `.streamlit/secrets.toml` with valid TOML syntax for application variables (`XANO_AUTH_BASE_URL`, `XANO_COLLEGE_BASE_URL`, `EDUTRACK_API_BASE_URL`).
- Provide `.streamlit/secrets.toml.example` as a template for local development and deployment.
- Update `pages/3_👤_Perfil.py` to retrieve the authentication API base URL (`XANO_AUTH_BASE_URL`) via `st.secrets`, removing manual parsing of `.env`.
- Update `pages/1 _Disciplinas.py` to retrieve backend API base URLs and authentication tokens via `st.secrets`, removing manual parsing of `.env`.
- Update `pages/2_Tarefas.py` to retrieve backend API base URLs and authentication tokens via `st.secrets`, removing manual parsing of `.env`.
- Update `pages/3_Files.py` to retrieve backend API base URLs and authentication tokens via `st.secrets`, removing manual parsing of `.env`.
- Update `.gitignore` to ensure `.streamlit/secrets.toml` is ignored from version control.

## Capabilities

### Modified Capabilities
- `user-auth`: Migrate API base URL configuration in `pages/3_👤_Perfil.py` from `.env` file parsing to Streamlit secrets (`st.secrets`).
- `subjects`: Migrate backend URL and token resolution in `pages/1 _Disciplinas.py` from `.env` file parsing to Streamlit secrets (`st.secrets`).
- `academic-tasks`: Migrate backend URL and token resolution in `pages/2_Tarefas.py` from `.env` file parsing to Streamlit secrets (`st.secrets`).
- `student-performance-report`: Migrate backend URL and token resolution in `pages/3_Files.py` from `.env` file parsing to Streamlit secrets (`st.secrets`).

## Impact

- Frontend pages modified:
  - `pages/3_👤_Perfil.py`
  - `pages/1 _Disciplinas.py`
  - `pages/2_Tarefas.py`
  - `pages/3_Files.py`
- Configuration files:
  - `.streamlit/secrets.toml` formatted with valid TOML key-value pairs.
  - `.streamlit/secrets.toml.example` created as a template.
  - `.gitignore` updated to ignore `.streamlit/secrets.toml`.
- Backend endpoints and schemas:
  - No changes required to backend Xano database tables or endpoints.
