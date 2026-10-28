"""
EduTrack AI - Academic Tasks Management Screen
Synchronizes academic tasks interface with Xano CRUD endpoints.
"""

from datetime import date
import os
from pathlib import Path
from typing import Any, Dict, List, Optional
import requests
import streamlit as st

st.set_page_config(page_title="Tarefas - EduTrack AI", page_icon="📝")

COMPLETED_STATUSES = {"completed", "concluida", "concluída", "done"}


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
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao buscar disciplinas."
        raise RuntimeError(error_msg)

    data = response.json()
    if isinstance(data, list):
        return data
    elif isinstance(data, dict) and "response" in data:
        return data["response"]
    return [data] if data else []


def fetch_academic_tasks(base_url: str, token: str) -> List[Dict[str, Any]]:
    """
    Fetch all academic tasks belonging to the authenticated user from GET /academic_tasks.
    """
    endpoint = f"{base_url.rstrip('/')}/academic_tasks"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }
    response = requests.get(endpoint, headers=headers, timeout=10)
    if not response.ok:
        data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao buscar tarefas."
        raise RuntimeError(error_msg)

    data = response.json()
    if isinstance(data, list):
        return data
    elif isinstance(data, dict) and "response" in data:
        return data["response"]
    return [data] if data else []


def create_academic_task(
    base_url: str,
    token: str,
    title: str,
    description: Optional[str] = None,
    due_date: Optional[str] = None,
    status: str = "pending",
    subject_id: Optional[int] = None,
) -> Dict[str, Any]:
    """
    Create a new academic task record via POST /academic_tasks.
    """
    endpoint = f"{base_url.rstrip('/')}/academic_tasks"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    payload: Dict[str, Any] = {
        "title": title.strip(),
        "description": description.strip() if description else None,
        "due_date": due_date,
        "status": status,
        "subject_id": subject_id,
    }
    response = requests.post(endpoint, json=payload, headers=headers, timeout=10)
    data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}

    if not response.ok:
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao criar tarefa."
        raise RuntimeError(error_msg)

    return data


def update_academic_task_status(
    base_url: str,
    token: str,
    task_id: int,
    new_status: str,
) -> Dict[str, Any]:
    """
    Update task status via PATCH /academic_tasks/{academic_task_id}.
    """
    endpoint = f"{base_url.rstrip('/')}/academic_tasks/{task_id}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    payload = {"status": new_status}
    response = requests.patch(endpoint, json=payload, headers=headers, timeout=10)
    data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}

    if not response.ok:
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao atualizar tarefa."
        raise RuntimeError(error_msg)

    return data


def delete_academic_task(base_url: str, token: str, task_id: int) -> None:
    """
    Delete an academic task via DELETE /academic_tasks/{academic_task_id}.
    """
    endpoint = f"{base_url.rstrip('/')}/academic_tasks/{task_id}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }
    response = requests.delete(endpoint, headers=headers, timeout=10)
    if not response.ok:
        data = response.json() if response.headers.get("content-type", "").startswith("application/json") else {}
        error_msg = data.get("message") or data.get("error") or f"Erro {response.status_code}: falha ao excluir tarefa."
        raise RuntimeError(error_msg)


def format_due_date(raw_date: Any) -> str:
    """Format due date string or timestamp safely."""
    if not raw_date:
        return "Sem prazo definido"
    try:
        if isinstance(raw_date, (int, float)):
            from datetime import datetime
            timestamp = raw_date / 1000 if raw_date > 1e11 else raw_date
            return datetime.fromtimestamp(timestamp).strftime("%d/%m/%Y")
        date_str = str(raw_date).split("T")[0]
        parts = date_str.split("-")
        if len(parts) == 3:
            return f"{parts[2]}/{parts[1]}/{parts[0]}"
        return date_str
    except Exception:
        return str(raw_date)


def main() -> None:
    st.title("📝 Minhas Tarefas")

    base_url = load_environment()
    token = get_auth_token()

    if not token:
        st.warning("⚠️ Você precisa estar autenticado para visualizar e gerenciar suas tarefas.")
        st.info("Por favor, acesse a página de **Perfil** no menu lateral para fazer login ou criar sua conta.")
        return

    tab_tarefas, tab_nova = st.tabs(["📋 Minhas Tarefas", "➕ Nova Tarefa"])

    # Load subjects for display mapping and creation
    try:
        subjects_list = fetch_subjects(base_url, token)
    except Exception:
        subjects_list = []
    subjects_dict = {s.get("id"): s.get("name", "Disciplina sem nome") for s in subjects_list}

    with tab_tarefas:
        col1, col2 = st.columns([3, 1])

        with col1:
            search_query = st.text_input("Buscar tarefa...", placeholder="Ex: Estudar Pandas", key="search_tasks")

        with col2:
            status_filter = st.selectbox("Status", ["Todas", "Pendente", "Concluída"], key="status_filter")

        st.markdown("---")

        try:
            tasks = fetch_academic_tasks(base_url, token)
        except Exception as exc:
            st.error(f"Erro ao carregar tarefas do backend: {exc}")
            if st.button("🔄 Tentar novamente", key="retry_tasks"):
                st.rerun()
            return

        # Apply filtering
        filtered_tasks = []
        for task in tasks:
            title = str(task.get("title", "")).lower()
            description = str(task.get("description") or "").lower()
            status_val = str(task.get("status", "")).strip().lower()
            is_completed = status_val in COMPLETED_STATUSES

            # Filter by search
            if search_query:
                query = search_query.strip().lower()
                if query not in title and query not in description:
                    continue

            # Filter by status
            if status_filter == "Pendente" and is_completed:
                continue
            if status_filter == "Concluída" and not is_completed:
                continue

            filtered_tasks.append(task)

        if not filtered_tasks:
            if not tasks:
                st.info("Nenhuma tarefa cadastrada ainda. Utilize a aba '➕ Nova Tarefa' para criar sua primeira atividade!")
            else:
                st.info("Nenhuma tarefa corresponde aos filtros selecionados.")
        else:
            for task in filtered_tasks:
                task_id = task.get("id")
                task_title = task.get("title", "Tarefa sem título")
                subject_id = task.get("subject_id")
                subject_name = subjects_dict.get(subject_id, "Geral / Sem Disciplina")
                due_date_str = format_due_date(task.get("due_date"))
                task_desc = task.get("description")
                current_status = str(task.get("status", "")).strip().lower()
                is_completed = current_status in COMPLETED_STATUSES

                icon = "✅" if is_completed else "📌"
                status_label = "Concluída" if is_completed else "Pendente"
                expander_label = f"{icon} {task_title} ({status_label})"

                with st.expander(expander_label, expanded=not is_completed):
                    col_info, col_action = st.columns([3, 1])
                    with col_info:
                        st.write(f"**Disciplina:** {subject_name}")
                        st.write(f"**Prazo:** {due_date_str}")
                        if task_desc:
                            st.write(f"**Descrição:** {task_desc}")

                    with col_action:
                        checked = st.checkbox(
                            "Marcar como Concluída",
                            value=is_completed,
                            key=f"task_check_{task_id}",
                        )
                        if checked != is_completed:
                            new_status = "completed" if checked else "pending"
                            try:
                                update_academic_task_status(base_url, token, task_id, new_status)
                                st.rerun()
                            except Exception as exc:
                                st.error(f"Erro ao atualizar status: {exc}")

                        if st.button("🗑️ Excluir", key=f"del_task_{task_id}", type="secondary"):
                            try:
                                delete_academic_task(base_url, token, task_id)
                                st.success("Tarefa excluída com sucesso!")
                                st.rerun()
                            except Exception as exc:
                                st.error(f"Erro ao excluir tarefa: {exc}")

            st.caption(f"Exibindo {len(filtered_tasks)} de {len(tasks)} tarefa(s)")

    with tab_nova:
        st.subheader("Cadastrar Nova Tarefa")
        with st.form("form_nova_tarefa"):
            title = st.text_input("Título da Tarefa*", placeholder="Ex: Entrega do Projeto Final")

            subject_options: Dict[str, Optional[int]] = {"Geral / Sem Disciplina": None}
            for s in subjects_list:
                s_id = s.get("id")
                s_name = s.get("name", "Sem nome")
                s_code = s.get("code")
                display_name = f"{s_name} ({s_code})" if s_code else s_name
                subject_options[display_name] = s_id

            selected_subject_label = st.selectbox("Disciplina Associada", list(subject_options.keys()))
            selected_subject_id = subject_options[selected_subject_label]

            has_due_date = st.checkbox("Definir prazo de entrega", value=False)
            task_due_date: Optional[date] = None
            if has_due_date:
                task_due_date = st.date_input("Data de Entrega", value=date.today())

            description = st.text_area("Descrição da Tarefa", placeholder="Ex: Instruções, referências e requisitos")
            initial_status = st.selectbox("Status Inicial", ["Pendente", "Concluída"])

            submitted = st.form_submit_button("Salvar Tarefa", type="primary")
            if submitted:
                if not title.strip():
                    st.error("O título da tarefa é obrigatório.")
                else:
                    due_date_payload = task_due_date.isoformat() if (has_due_date and task_due_date) else None
                    status_payload = "completed" if initial_status == "Concluída" else "pending"

                    try:
                        create_academic_task(
                            base_url=base_url,
                            token=token,
                            title=title,
                            description=description,
                            due_date=due_date_payload,
                            status=status_payload,
                            subject_id=selected_subject_id,
                        )
                        st.success(f"Tarefa '{title}' cadastrada com sucesso no Xano!")
                        st.rerun()
                    except Exception as exc:
                        st.error(f"Falha ao cadastrar tarefa: {exc}")


if __name__ == "__main__":
    main()
