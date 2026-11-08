"""
EduTrack AI - Academic Files & Performance Reports Screen
Allows students to view consolidated academic performance metrics and download a PDF report.
"""

from datetime import date
import os
from pathlib import Path
import tempfile
from typing import Any, Dict, List, Optional
import requests
import streamlit as st

from scripts.generate_performance_report import (
    calculate_student_performance,
    generate_performance_report_pdf,
)

st.set_page_config(page_title="Relatórios e Arquivos - EduTrack AI", page_icon="📄")


def load_environment() -> str:
    """
    Load environment configuration from Streamlit secrets (with fallback to environment variables)
    and return the college API base URL.
    """
    try:
        for key in ("EDUTRACK_API_BASE_URL", "XANO_COLLEGE_BASE_URL"):
            if key in st.secrets:
                os.environ.setdefault(key, str(st.secrets[key]).strip())
    except Exception:
        pass

    return (
        os.getenv("EDUTRACK_API_BASE_URL")
        or os.getenv("XANO_COLLEGE_BASE_URL", "https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0")
    )


def get_auth_token() -> Optional[str]:
    """Retrieve authentication token from session state, Streamlit secrets, or environment variable."""
    token = st.session_state.get("auth_token")
    if token:
        return token
    try:
        if "EDUTRACK_AUTH_TOKEN" in st.secrets:
            return str(st.secrets["EDUTRACK_AUTH_TOKEN"]).strip()
    except Exception:
        pass
    return os.getenv("EDUTRACK_AUTH_TOKEN")


def fetch_student_data(base_url: str, token: str) -> tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """
    Fetch subjects and academic tasks from backend endpoints.
    Tries the consolidated student_performance_report endpoint first,
    falling back to individual endpoints if needed.
    """
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }

    # 1. Try consolidated endpoint
    try:
        report_url = f"{base_url.rstrip('/')}/student_performance_report"
        resp = requests.get(report_url, headers=headers, timeout=5)
        if resp.ok:
            data = resp.json()
            target = data[0] if (isinstance(data, list) and len(data) > 0 and isinstance(data[0], dict)) else data
            if isinstance(target, dict) and ("subjects" in target or "academic_tasks" in target):
                return target.get("subjects", []), target.get("academic_tasks", [])
    except Exception:
        pass

    # 2. Fallback to separate endpoints
    subjects: List[Dict[str, Any]] = []
    tasks: List[Dict[str, Any]] = []

    try:
        sub_resp = requests.get(f"{base_url.rstrip('/')}/subjects", headers=headers, timeout=10)
        if sub_resp.ok:
            s_data = sub_resp.json()
            subjects = s_data if isinstance(s_data, list) else s_data.get("response", [])
    except Exception as exc:
        st.warning(f"Não foi possível carregar disciplinas: {exc}")

    try:
        task_resp = requests.get(f"{base_url.rstrip('/')}/academic_tasks", headers=headers, timeout=10)
        if task_resp.ok:
            t_data = task_resp.json()
            tasks = t_data if isinstance(t_data, list) else t_data.get("response", [])
    except Exception as exc:
        st.warning(f"Não foi possível carregar tarefas: {exc}")

    return subjects, tasks


def build_pdf_report(subjects: List[Dict[str, Any]], tasks: List[Dict[str, Any]]) -> bytes:
    """Generate PDF report and return binary bytes."""
    perf = calculate_student_performance(subjects, tasks)
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp_file:
        tmp_path = tmp_file.name

    try:
        generate_performance_report_pdf(perf, tmp_path)
        with open(tmp_path, "rb") as f:
            pdf_bytes = f.read()
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)

    return pdf_bytes


def main() -> None:
    st.title("📄 Relatórios e Arquivos Acadêmicos")
    st.write("Visualize o seu resumo de rendimento acadêmico e exporte seu relatório completo em formato PDF.")

    base_url = load_environment()
    token = get_auth_token()

    if not token:
        st.warning("⚠️ Você precisa estar autenticado para acessar seus relatórios.")
        st.info("Por favor, acesse a página de **Perfil** no menu lateral para fazer login ou criar sua conta.")
        return

    # Load data
    with st.spinner("Carregando dados acadêmicos..."):
        try:
            subjects, tasks = fetch_student_data(base_url, token)
        except Exception as exc:
            st.error(f"Erro ao consultar dados: {exc}")
            subjects, tasks = [], []

    # Calculate performance metrics
    performance = calculate_student_performance(subjects, tasks)

    # Metric Cards
    col1, col2, col3, col4 = st.columns(4)
    overall_pct = performance.get("overall_progress_percentage", 0.0)
    col1.metric("Progresso Geral", f"{overall_pct}%")
    col2.metric("Disciplinas", str(performance.get("total_subjects", 0)))
    col3.metric("Tarefas Concluídas", str(performance.get("completed_tasks", 0)))
    col4.metric("Tarefas Pendentes", str(performance.get("pending_tasks", 0)))

    st.progress(min(max(overall_pct / 100.0, 0.0), 1.0))

    st.markdown("---")

    # Section: Report Generation & Download
    st.subheader("📥 Exportação de Relatório")
    st.write("Clique no botão abaixo para gerar o arquivo PDF consolidado com suas disciplinas, tarefas e porcentagens de conclusão.")

    try:
        pdf_data = build_pdf_report(subjects, tasks)
        today_str = date.today().isoformat()
        file_name = f"edutrack_desempenho_{today_str}.pdf"

        st.download_button(
            label="📄 Baixar Relatório de Desempenho (PDF)",
            data=pdf_data,
            file_name=file_name,
            mime="application/pdf",
            type="primary",
            use_container_width=True,
        )
    except Exception as exc:
        st.error(f"Erro ao preparar o relatório em PDF: {exc}")

    st.markdown("---")

    # Section: Detailed Breakdown by Subject
    st.subheader("📊 Desempenho por Disciplina")
    subjects_stats = performance.get("subjects", [])

    if not subjects_stats:
        st.info("Nenhuma disciplina vinculada encontrada. Cadastre disciplinas e tarefas para gerar métricas detalhadas.")
    else:
        table_rows = []
        for s in subjects_stats:
            table_rows.append(
                {
                    "Disciplina": s.get("name"),
                    "Código": s.get("code"),
                    "Tarefas Concluídas": s.get("completed_tasks"),
                    "Total de Tarefas": s.get("total_tasks"),
                    "Progresso": f"{s.get('progress_percentage')}%",
                }
            )
        st.dataframe(table_rows, use_container_width=True)

    # Section: Recent Tasks
    with st.expander("📝 Visualizar Tarefas Consideradas no Relatório", expanded=False):
        all_tasks = performance.get("all_tasks", [])
        if not all_tasks:
            st.write("Nenhuma tarefa acadêmica registrada.")
        else:
            task_rows = []
            for t in all_tasks:
                task_rows.append(
                    {
                        "ID": t.get("id"),
                        "Título": t.get("title"),
                        "Prazo": t.get("due_date") or "-",
                        "Status": "Concluída" if str(t.get("status", "")).lower() in {"completed", "done", "concluida", "concluída"} else "Pendente",
                    }
                )
            st.dataframe(task_rows, use_container_width=True)


if __name__ == "__main__":
    main()
