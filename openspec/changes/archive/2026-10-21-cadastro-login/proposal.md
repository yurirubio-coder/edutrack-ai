## Why

Users need an authentication and profile interface in Streamlit to register their accounts, log into the platform, and inspect their profile data. The underlying user table and authentication endpoints (`auth/signup`, `auth/login`, `auth/me`) already exist in Xano, but there is currently no client page in `pages/3_👤_Perfil.py` connecting the frontend with these endpoints, nor an environment file (`.env`) configuring the base API URL.

## What Changes

- Store the authentication API base URL in a `.env` file at the root of the project.
- Implement a Python Streamlit script in `pages/3_👤_Perfil.py` providing authentication and profile interfaces.
- Integrate user registration with `POST auth/signup` to persist new users into the `user` table.
- Integrate user login with `POST auth/login` to authenticate users and persist the session token.
- Integrate user profile retrieval with `GET auth/me` using the authenticated user's Bearer token.

## Capabilities

### New Capabilities
- `user-auth`: User registration, login, and authenticated profile display in Streamlit using Xano authentication endpoints (`auth/signup`, `auth/login`, `auth/me`) and environment-based configuration.

### Modified Capabilities

## Impact

- New configuration file: `.env` at root holding `XANO_AUTH_BASE_URL`.
- New Streamlit page: `pages/3_👤_Perfil.py`.
- Integrates with existing backend endpoints: `POST auth/signup`, `POST auth/login`, and `GET auth/me` (canonical group `Authentication`).
- Persists user records in the existing `user` table.
- No changes required to backend XanoScript schema or endpoints.

