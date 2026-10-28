## Why

Now that user authentication and login are operational and the session authentication token is available in `st.session_state`, the application pages for subjects (`pages/1 _Disciplinas.py`) and academic tasks (`pages/2_Tarefas.py`) need to load and mutate real data from the Xano backend endpoints instead of using placeholder mockups. The backend endpoints under the `College` group (`api:ILKDtEV0`) enforce student data isolation via `$auth.id`, and connecting the Streamlit frontend allows students to manage their subjects and tasks in real time.

## What Changes

- Sincronizar a página de disciplinas (`pages/1 _Disciplinas.py`) com os endpoints do Xano:
  - Carregar e exibir disciplinas via `GET https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects` autenticando com o Bearer token do usuário.
  - Cadastrar novas disciplinas via `POST https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects`.
- Sincronizar a página de tarefas (`pages/2_Tarefas.py`) com os endpoints do Xano:
  - Carregar e exibir tarefas acadêmicas via `GET https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks`.
  - Criar tarefas acadêmicas via `POST https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks`.
  - Atualizar status de conclusão de tarefas via `PATCH https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}`.
  - Excluir tarefas acadêmicas via `DELETE https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}`.
  - Carregar disciplinas para associar nomes de disciplinas às tarefas.

## Capabilities

### Modified Capabilities
- `subjects`: Synchronize frontend interface `pages/1 _Disciplinas.py` with Xano `GET /subjects` and `POST /subjects` endpoints using authenticated session context.
- `academic-tasks`: Synchronize frontend interface `pages/2_Tarefas.py` with Xano `GET /academic_tasks`, `POST /academic_tasks`, `PATCH /academic_tasks/{academic_task_id}`, and `DELETE /academic_tasks/{academic_task_id}` endpoints using authenticated session context.

## Impact

- Modified frontend pages:
  - `pages/1 _Disciplinas.py`: Replaces static placeholder dataframe with live queries to `GET /subjects` and subject registration via `POST /subjects`.
  - `pages/2_Tarefas.py`: Replaces static mockup expander with live task queries (`GET /academic_tasks`), task creation (`POST /academic_tasks`), status mutation (`PATCH /academic_tasks/{academic_task_id}`), and task deletion (`DELETE /academic_tasks/{academic_task_id}`).
- Backend endpoints consumed under group `api:ILKDtEV0`:
  - `(GET) https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks`
  - `(POST) https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks`
  - `(DELETE) https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}`
  - `(PATCH) https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/academic_tasks/{academic_task_id}`
  - `(GET) https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects`
  - `(POST) https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0/subjects`
- No changes required to backend XanoScript schema or endpoints.

