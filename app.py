import streamlit as st
from services import subject_service

# Configuração da Página (Título na aba do navegador)
st.set_page_config(page_title="EduTrack AI", page_icon="🎓", layout="wide")

# Título Principal
st.title("🎓 EduTrack AI")

# Sidebar (Menu Lateral)
st.sidebar.header("Menu")
menu_option = st.sidebar.radio("Navegar", ["Dashboard", "Disciplinas", "Tarefas"])

# Conteúdo Dinâmico
if menu_option == "Dashboard":
    st.write("Bem-vindo ao seu assistente acadêmico!")
    
    if subject_service.is_xano_configured():
        st.success("Conectado ao backend Xano.")
    else:
        st.info("Modo local ativo (dados salvos na sessão). Conecte ao Xano para sincronização em nuvem.")
    
    # Métricas Visuais Dinâmicas
    col1, col2 = st.columns(2)
    active_count = subject_service.count_active_subjects()
    col1.metric("Disciplinas Ativas", str(active_count))
    col2.metric("Tarefas Pendentes", "0")

elif menu_option == "Disciplinas":
    st.subheader("📚 Minhas Disciplinas")
    
    # Formulário de Cadastro de Disciplina
    with st.expander("➕ Cadastrar Nova Disciplina", expanded=False):
        with st.form("new_subject_form", clear_on_submit=True):
            name = st.text_input("Nome da Disciplina *", placeholder="Ex: Engenharia de Software")
            col_f1, col_f2 = st.columns(2)
            code = col_f1.text_input("Código / Sigla", placeholder="Ex: ES-101")
            professor = col_f2.text_input("Professor(a)", placeholder="Ex: Prof. Carlos")
            col_f3, col_f4 = st.columns(2)
            workload = col_f3.number_input("Carga Horária (horas)", min_value=0, max_value=500, value=60, step=10)
            status = col_f4.selectbox(
                "Status Inicial",
                ["active", "archived"],
                format_func=lambda x: "Ativa" if x == "active" else "Arquivada"
            )
            submitted = st.form_submit_button("Salvar Disciplina", use_container_width=True)

            if submitted:
                if not name.strip():
                    st.error("O nome da disciplina é obrigatório!")
                else:
                    try:
                        subject_service.create_subject(
                            name=name,
                            code=code,
                            professor=professor,
                            workload_hours=int(workload),
                            status=status
                        )
                        st.success(f"Disciplina '{name}' cadastrada com sucesso!")
                        st.rerun()
                    except Exception as e:
                        st.error(f"Erro ao cadastrar disciplina: {e}")

    # Filtros e Estatísticas Rápidas
    all_subjects = subject_service.get_subjects()
    
    filter_col1, filter_col2 = st.columns([3, 1])
    filter_option = filter_col2.selectbox(
        "Filtrar por Status",
        ["Todas", "Ativas", "Arquivadas"],
        index=0
    )

    if filter_option == "Ativas":
        displayed_subjects = [s for s in all_subjects if s.get("status") == "active"]
    elif filter_option == "Arquivadas":
        displayed_subjects = [s for s in all_subjects if s.get("status") == "archived"]
    else:
        displayed_subjects = all_subjects

    # Listagem de Disciplinas
    if not displayed_subjects:
        st.info("Nenhuma disciplina encontrada. Cadastre sua primeira disciplina no formulário acima para começar!")
    else:
        for s in displayed_subjects:
            with st.container(border=True):
                c1, c2, c3 = st.columns([3, 2, 1.5])
                with c1:
                    st.markdown(f"### {s['name']}")
                    if s.get("code"):
                        st.caption(f"Código: `{s['code']}`")
                with c2:
                    teacher_name = s.get("teacher") or s.get("professor")
                    if teacher_name:
                        st.write(f"👨‍🏫 **Professor(a):** {teacher_name}")
                    hours_val = s.get("hours") or s.get("workload_hours")
                    if hours_val:
                        st.write(f"⏱️ **Carga Horária:** {hours_val}h")
                with c3:
                    is_active = s.get("status") == "active"
                    badge_label = "🟢 Ativa" if is_active else "⚪ Arquivada"
                    st.markdown(f"**Status:** {badge_label}")
                    toggle_label = "Arquivar" if is_active else "Reativar"
                    if st.button(toggle_label, key=f"toggle_{s['id']}", use_container_width=True):
                        subject_service.toggle_subject_status(s['id'])
                        st.rerun()

elif menu_option == "Tarefas":
    st.subheader("Gerenciamento de Tarefas")
    st.checkbox("Exemplo: Estudar Streamlit")
