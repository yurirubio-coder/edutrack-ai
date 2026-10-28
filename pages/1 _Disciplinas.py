"""
EduTrack AI - Subjects Management Screen
Synchronizes subjects management interface with Xano CRUD endpoints.
"""

import os
from pathlib import Path
from typing import Any, Dict, List, Optional
import requests
import streamlit as st

st.set_page_config(page_title="Disciplinas - EduTrack AI", page_icon="📚")


def load_environment() -> str:
    """
    Load environment configuration from the root .env file and return the college API base URL.
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
        except Exception:
            pass

    return os.getenv(
        "EDUTRACK_API_BASE_URL",
        os.getenv("XANO_COLLEGE_BASE_URL", "https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0"),
    )


def get_auth_token() -> Optional[str]:
    """
    Retrieve authentication token from session state or environment variable.
    """
    return st.session_state.get("auth_token") or os.getenv("EDUTRACK_AUTH_TOKEN")


def fetch_subjects(base_url: str, token: str) -> List[Dict[str, Any]]:
    """
    Fetch all subjects belonging to the authenticated user from GET /subjects.
    """
    endpoint = f"{base_url.rstrip('/')}/subjects"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }
    response = requests.get(endpoint, headers=headers, timeout=10)
    if not response.ok:
        data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao listar disciplinas."
        raise RuntimeError(error_msg)

    data = response.json()
    if isinstance(data, list):
        return data
    elif isinstance(data, dict) and "response" in data:
        return data["response"]
    return [data] if data else []


def create_subject(
    base_url: str,
    token: str,
    name: str,
    code: Optional[str] = None,
    description: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Create a new subject record linked to the authenticated user via POST /subjects.
    """
    endpoint = f"{base_url.rstrip('/')}/subjects"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    payload: Dict[str, Any] = {
        "name": name.strip(),
        "code": code.strip() if code else None,
        "description": description.strip() if description else None,
    }
    response = requests.post(endpoint, json=payload, headers=headers, timeout=10)
    data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}

    if not response.ok:
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao cadastrar disciplina."
        raise RuntimeError(error_msg)

    return data


def main() -> None:
    st.title("📚 Gestão de Disciplinas")

    base_url = load_environment()
    token = get_auth_token()

    if not token:
        st.warning("⚠️ Você precisa estar autenticado para acessar suas disciplinas.")
        st.info("Por favor, acesse a página de **Perfil** no menu lateral para fazer login ou criar sua conta.")
        return

    tab_lista, tab_novo = st.tabs(["📋 Listar", "➕ Nova Disciplina"])

    with tab_lista:
        st.subheader("Minhas Disciplinas")
        try:
            subjects = fetch_subjects(base_url, token)
            if not subjects:
                st.info("Nenhuma disciplina cadastrada ainda. Utilize a aba '➕ Nova Disciplina' para cadastrar sua primeira matéria!")
            else:
                table_data = [
                    {
                        "ID": s.get("id"),
                        "Nome": s.get("name", "-"),
                        "Código": s.get("code") or "-",
                        "Descrição": s.get("description") or "-",
                    }
                    for s in subjects
                ]
                st.dataframe(table_data, use_container_width=True)
                st.caption(f"Total: {len(subjects)} disciplina(s) cadastrada(s)")
        except Exception as exc:
            st.error(f"Erro ao carregar disciplinas do backend: {exc}")
            if st.button("🔄 Tentar novamente"):
                st.rerun()

    with tab_novo:
        st.subheader("Cadastrar Nova Disciplina")
        with st.form("form_disciplina"):
            name = st.text_input("Nome da Disciplina*", placeholder="Ex: Engenharia de Software")
            code = st.text_input("Código da Matéria", placeholder="Ex: ES101")
            description = st.text_area("Descrição / Informações", placeholder="Ex: Prof. Oriel - Segundas-feiras")

            submitted = st.form_submit_button("Salvar Disciplina", type="primary")
            if submitted:
                if not name.strip():
                    st.error("O nome da disciplina é obrigatório.")
                else:
                    try:
                        create_subject(base_url, token, name, code, description)
                        st.success(f"Disciplina '{name}' cadastrada com sucesso no Xano!")
                        st.rerun()
                    except Exception as exc:
                        st.error(f"Falha ao cadastrar disciplina: {exc}")


if __name__ == "__main__":
    main()
