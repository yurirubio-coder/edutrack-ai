## Context

EduTrack AI uses Streamlit as its user-facing web interface and Xano as backend. The authentication endpoints `auth/signup`, `auth/login`, and `auth/me` are defined under the Authentication API group (`api_group Authentication { canonical = "Zet0FedP" }`), which reads and mutates the `user` table. To allow students to register, log in, and view their profile, a dedicated Streamlit page `pages/3_👤_Perfil.py` is planned. The base URL for authentication endpoints will be kept in a `.env` file at the root of the project.

## Goals / Non-Goals

**Goals:**
- Configure the authentication endpoint base URL in a `.env` file at the project root (`XANO_AUTH_BASE_URL`).
- Implement `pages/3_👤_Perfil.py` with Streamlit.
- Provide a registration interface submitting to `POST /auth/signup` and persisting data into the `user` table.
- Provide a login interface submitting to `POST /auth/login` and storing the returned `authToken` in `st.session_state`.
- Provide an authenticated profile view calling `GET /auth/me` with Bearer token authentication to display user details.

**Non-Goals:**
- Implementing password reset or recovery workflows (not requested).
- Implementing email or SMS verification codes (not requested).
- Altering the Xano database schema or existing `.xs` endpoints (not requested).
- Modifying other Streamlit pages in `pages/` (not requested).

## Decisions

- **Configuration Management**:
  - Store `XANO_AUTH_BASE_URL=https://x8ki-letl-twmt.n7.xano.io/api:Zet0FedP` in `.env` at the project root.
  - Ensure `.env` is loaded safely with a fallback default.
- **HTTP Client**:
  - Utilize `requests` (already included in `requirements.txt`) or `urllib` to dispatch JSON payloads and parse responses.
- **Session Management**:
  - Store `auth_token` and `user_info` in `st.session_state` (`st.session_state.auth_token`, `st.session_state.user`).
- **Interface Structure**:
  - In `pages/3_👤_Perfil.py`, provide clear tabs or state switching:
    - Tab 1: "🔑 Login" (Email, Password fields).
    - Tab 2: "📝 Cadastro" (Name, Email, Password fields).
    - Tab 3: "👤 Perfil" (Displays authenticated user details retrieved via `GET auth/me`).

## Risks / Trade-offs

- **Risk**: Missing or improperly loaded `.env` file leads to connection errors.
  - **Mitigation**: Parse `.env` using robust file reading and provide fallback defaults or a clear error banner.
- **Risk**: Expired or invalid token when calling `GET auth/me`.
  - **Mitigation**: Handle 401/403 responses gracefully by clearing session state and prompting the user to re-authenticate.

