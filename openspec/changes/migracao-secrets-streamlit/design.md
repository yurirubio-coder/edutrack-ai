## Context

EduTrack AI's frontend is developed in Python using the Streamlit framework. The application interfaces with Xano backend endpoints for user authentication, academic tasks, subjects, and performance reports. Previously, configuration parameters such as `XANO_AUTH_BASE_URL` and `XANO_COLLEGE_BASE_URL` were extracted by having each Streamlit page read a `.env` file at runtime. Streamlit natively supplies `st.secrets`, which manages configurations stored in `.streamlit/secrets.toml` during local development and platform secrets in hosted environments.

## Goals / Non-Goals

**Goals:**
- Replace manual `.env` file parsing across all Streamlit pages with `st.secrets`.
- Ensure robust fallback to `os.getenv` and default canonical URLs when secrets are unavailable or keys are missing.
- Format `.streamlit/secrets.toml` with valid TOML syntax.
- Ensure the sensitive `.streamlit/secrets.toml` file is excluded by `.gitignore`.

**Non-Goals:**
- Altering any XanoScript backend schemas, database tables, or API endpoints.
- Removing CLI arguments or environment variable support in standalone CLI scripts.
- Adding unrequested third-party secret managers.

## Decisions

- **Configuration Resolution Precedence**:
  In each page's `load_environment()`:
  1. Check `st.secrets` for the required configuration keys.
  2. If found, populate `os.environ.setdefault()` so any submodules or helper functions also access them.
  3. If not present in `st.secrets` or if `st.secrets` raises an exception (e.g., secrets file missing), fall back to `os.getenv()`.
  4. Fall back to the default canonical Xano URL as a final safety net.
- **Graceful Error Handling**:
  Wrap all `st.secrets` inspections in try/except blocks to prevent runtime failures if Streamlit runs in environments where secrets are not yet configured.
- **Valid TOML Configuration**:
  Configure `.streamlit/secrets.toml` with quoted string values matching TOML specification:
  ```toml
  XANO_AUTH_BASE_URL = "https://x8ki-letl-twmt.n7.xano.io/api:Zet0FedP"
  XANO_COLLEGE_BASE_URL = "https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0"
  EDUTRACK_API_BASE_URL = "https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0"
  ```

## Risks / Trade-offs

- **Risk**: Streamlit raises `StreamlitSecretNotFoundError` when `.streamlit/secrets.toml` is absent.
  - **Mitigation**: Access `st.secrets` inside a `try...except Exception` block, falling back safely to `os.getenv()` and predefined default URLs.
