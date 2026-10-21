"""
EduTrack AI - Profile & Authentication Page
Handles user signup, login, and authenticated profile consultation using Xano authentication endpoints.
"""

import os
from pathlib import Path
from typing import Any, Dict, Optional
import requests
import streamlit as st

# Configure page settings
st.set_page_config(page_title="Perfil - EduTrack AI", page_icon="👤")


def load_environment() -> str:
    """
    Load environment variables from the root .env file and return the authentication base URL.
    """
    root_dir = Path(__file__).resolve().parent.parent
    env_file = root_dir / ".env"

    if env_file.is_file():
        try:
            with open(env_file, "r", encoding="utf-8") as f:
                for line in f:
                    stripped = line.strip()
                    if stripped and not stripped.startswith("#") and "=" in stripped:
                        key, val = stripped.split("=", 1)
                        os.environ.setdefault(key.strip(), val.strip())
        except Exception as e:
            st.warning(f"Não foi possível ler o arquivo .env: {e}")

    return os.getenv("XANO_AUTH_BASE_URL", "https://x8ki-letl-twmt.n7.xano.io/api:Zet0FedP")


def signup_user(base_url: str, name: str, email: str, password: str) -> Dict[str, Any]:
    """
    Register a new user in the platform via POST auth/signup.
    Saves record into the user table and returns authentication token.
    """
    endpoint = f"{base_url.rstrip('/')}/auth/signup"
    payload = {
        "name": name.strip(),
        "email": email.strip().lower(),
        "password": password,
    }
    response = requests.post(endpoint, json=payload, timeout=10)
    data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}

    if not response.ok:
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao cadastrar."
        raise RuntimeError(error_msg)

    return data


def login_user(base_url: str, email: str, password: str) -> Dict[str, Any]:
    """
    Authenticate an existing user via POST auth/login.
    Returns authentication token and user_id.
    """
    endpoint = f"{base_url.rstrip('/')}/auth/login"
    payload = {
        "email": email.strip().lower(),
        "password": password,
    }
    response = requests.post(endpoint, json=payload, timeout=10)
    data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}

    if not response.ok:
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: credenciais inválidas."
        raise RuntimeError(error_msg)

    return data


def fetch_user_profile(base_url: str, token: str) -> Dict[str, Any]:
    """
    Fetch authenticated user information via GET auth/me.
    """
    endpoint = f"{base_url.rstrip('/')}/auth/me"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }
    response = requests.get(endpoint, headers=headers, timeout=10)
    data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}

    if not response.ok:
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: sessão expirada ou inválida."
        raise RuntimeError(error_msg)

    return data


def init_session_state() -> None:
    """Initialize session state variables for authentication."""
    if "auth_token" not in st.session_state:
        st.session_state["auth_token"] = None
    if "user_id" not in st.session_state:
        st.session_state["user_id"] = None
    if "user_data" not in st.session_state:
        st.session_state["user_data"] = None


def render_authenticated_view(base_url: str) -> None:
    """Render profile details for logged-in user."""
    st.title("👤 Meu Perfil")

    token = st.session_state.get("auth_token")

    # Refresh user data if needed
    if not st.session_state.get("user_data") and token:
        try:
            st.session_state["user_data"] = fetch_user_profile(base_url, token)
        except Exception as exc:
            st.error(f"Erro ao obter dados do perfil: {exc}")
            if st.button("Tentar novamente"):
                st.rerun()
            return

    user = st.session_state.get("user_data") or {}

    st.success(f"Conectado como **{user.get('name', 'Estudante')}**")

    col1, col2 = st.columns(2)
    with col1:
        st.markdown("### 📋 Informações Pessoais")
        st.write(f"**Nome:** {user.get('name', '-')}")
        st.write(f"**E-mail:** {user.get('email', '-')}")
        st.write(f"**ID do Usuário:** {user.get('id', '-')}")

    with col2:
        st.markdown("### 🔒 Sessão")
        st.write("**Status:** Autenticado")
        st.write(f"**Endpoint Conectado:** `{base_url}`")

    st.markdown("---")
    if st.button("🚪 Sair da Conta", type="secondary"):
        st.session_state["auth_token"] = None
        st.session_state["user_id"] = None
        st.session_state["user_data"] = None
        st.success("Você saiu da sua conta.")
        st.rerun()


def render_unauthenticated_view(base_url: str) -> None:
    """Render login and registration forms."""
    st.title("👤 Acesso à Plataforma")
    st.info("Entre com suas credenciais ou crie uma conta para sincronizar seus dados acadêmicos.")

    tab_login, tab_signup = st.tabs(["🔑 Entrar", "📝 Cadastrar"])

    with tab_login:
        st.subheader("Login")
        with st.form("form_login"):
            login_email = st.text_input("E-mail", key="login_email")
            login_password = st.text_input("Senha", type="password", key="login_password")
            btn_login = st.form_submit_button("Entrar", type="primary", use_container_width=True)

            if btn_login:
                if not login_email or not login_password:
                    st.error("Por favor, preencha o e-mail e a senha.")
                else:
                    try:
                        auth_response = login_user(base_url, login_email, login_password)
                        token = auth_response.get("authToken")
                        user_id = auth_response.get("user_id")

                        st.session_state["auth_token"] = token
                        st.session_state["user_id"] = user_id

                        # Fetch full profile data using auth/me
                        profile = fetch_user_profile(base_url, token)
                        st.session_state["user_data"] = profile

                        st.success("Login efetuado com sucesso!")
                        st.rerun()
                    except Exception as exc:
                        st.error(f"Falha ao entrar: {exc}")

    with tab_signup:
        st.subheader("Novo Cadastro")
        with st.form("form_signup"):
            signup_name = st.text_input("Nome Completo", key="signup_name")
            signup_email = st.text_input("E-mail", key="signup_email")
            signup_password = st.text_input(
                "Senha (mínimo 8 caracteres, com letras e números)",
                type="password",
                key="signup_password",
            )
            btn_signup = st.form_submit_button("Criar Conta", type="primary", use_container_width=True)

            if btn_signup:
                if not signup_name or not signup_email or not signup_password:
                    st.error("Todos os campos são obrigatórios.")
                elif len(signup_password) < 8:
                    st.error("A senha deve ter pelo menos 8 caracteres.")
                else:
                    try:
                        signup_response = signup_user(base_url, signup_name, signup_email, signup_password)
                        token = signup_response.get("authToken")
                        user_id = signup_response.get("user_id")

                        st.session_state["auth_token"] = token
                        st.session_state["user_id"] = user_id

                        # Fetch full profile data using auth/me
                        profile = fetch_user_profile(base_url, token)
                        st.session_state["user_data"] = profile

                        st.success("Cadastro realizado com sucesso! Seus dados foram salvos.")
                        st.rerun()
                    except Exception as exc:
                        st.error(f"Falha ao cadastrar: {exc}")


def main() -> None:
    """Main entrypoint for the Profile & Authentication page."""
    init_session_state()
    base_url = load_environment()

    if st.session_state.get("auth_token"):
        render_authenticated_view(base_url)
    else:
        render_unauthenticated_view(base_url)


if __name__ == "__main__":
    main()

