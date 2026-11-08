# user-auth Specification

## Purpose
Provides configuration loading from Streamlit secrets for user authentication and college API endpoints in EduTrack AI.

## ADDED Requirements

### Requirement: Load configuration from Streamlit secrets
The system SHALL load API base URLs and authentication tokens from Streamlit secrets (`st.secrets`) with safe fallback to system environment variables and default endpoint URLs.

#### Scenario: Read configuration from Streamlit secrets
- **WHEN** the application initializes a page requiring backend API access
- **THEN** the system SHALL attempt to read the configured base URL from `st.secrets`

#### Scenario: Fallback when secrets are absent or key is missing
- **WHEN** a configuration key is not present in `st.secrets` or the secrets file is missing
- **THEN** the system SHALL fall back to `os.getenv` or predefined canonical default URLs without raising unhandled exceptions

### Requirement: Streamlit secrets file configuration
The system SHALL support configuration through `.streamlit/secrets.toml` containing valid TOML key-value pairs for API base URLs.

#### Scenario: Application starts with configured secrets.toml
- **WHEN** the application starts with a valid `.streamlit/secrets.toml` file
- **THEN** the system SHALL load `XANO_AUTH_BASE_URL` and `XANO_COLLEGE_BASE_URL` from the secrets store
