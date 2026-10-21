# user-auth Specification

## Purpose
Provides user registration, login authentication, and profile consultation in EduTrack AI via Streamlit and Xano authentication endpoints with environment configuration.

## ADDED Requirements

### Requirement: Authentication base URL configuration
The system SHALL load the base URL for authentication endpoints from a `.env` file located in the project root directory (`XANO_AUTH_BASE_URL`).

#### Scenario: Read base URL from environment file
- **WHEN** the profile and authentication module initializes
- **THEN** the system SHALL load the configured base URL from `.env`

### Requirement: User registration
The system SHALL provide a registration form in `pages/3_👤_Perfil.py` that submits user data (name, email, password) to `POST auth/signup` to persist new user records in the `user` table.

#### Scenario: Successful registration
- **WHEN** a user provides valid registration inputs (name, email, password) and submits the form
- **THEN** the system SHALL send a POST request to `auth/signup`, store the user in the `user` table, and return the authentication token

#### Scenario: Registration failure with duplicate email
- **WHEN** a user submits registration inputs with an email that is already registered
- **THEN** the system SHALL display an error message and prevent duplicate user creation

### Requirement: User login
The system SHALL provide a login form in `pages/3_👤_Perfil.py` that submits credentials (email, password) to `POST auth/login` and persists the session authentication token.

#### Scenario: Successful login
- **WHEN** a user submits valid login credentials (email and password)
- **THEN** the system SHALL send a POST request to `auth/login`, store the authentication token in `st.session_state`, and authenticate the session

#### Scenario: Login failure with invalid credentials
- **WHEN** a user submits incorrect email or password credentials
- **THEN** the system SHALL display an authentication error message and remain unauthenticated

### Requirement: User profile retrieval
The system SHALL fetch and display authenticated user details using `GET auth/me` with the stored Bearer authentication token.

#### Scenario: Display profile information for authenticated user
- **WHEN** an authenticated user views the profile page
- **THEN** the system SHALL request `GET auth/me` with the Bearer token and display the user's name, email, and identifier

