## 1. Configuração do Streamlit Secrets

- [x] 1.1 Formatar `.streamlit/secrets.toml` com sintaxe TOML válida para as variáveis da aplicação (`XANO_AUTH_BASE_URL`, `XANO_COLLEGE_BASE_URL`, `EDUTRACK_API_BASE_URL`)
- [x] 1.2 Criar `.streamlit/secrets.toml.example` como modelo de configuração
- [x] 1.3 Atualizar `.gitignore` para ignorar o arquivo `.streamlit/secrets.toml`

## 2. Migração da Leitura de Configuração nas Páginas Streamlit

- [x] 2.1 Atualizar `pages/3_👤_Perfil.py` para carregar `XANO_AUTH_BASE_URL` via `st.secrets` com fallback seguro
- [x] 2.2 Atualizar `pages/1 _Disciplinas.py` para carregar a URL base e token via `st.secrets` com fallback seguro
- [x] 2.3 Atualizar `pages/2_Tarefas.py` para carregar a URL base e token via `st.secrets` com fallback seguro
- [x] 2.4 Atualizar `pages/3_Files.py` para carregar a URL base e token via `st.secrets` com fallback seguro
