import os
import datetime
from typing import List, Dict, Any, Optional

try:
    import streamlit as st
except ImportError:
    st = None

try:
    import requests
except ImportError:
    requests = None

# Default seed subjects for immediate demonstration & fallback
INITIAL_SUBJECTS: List[Dict[str, Any]] = [
    {
        "id": 1,
        "name": "Innovation Lab",
        "code": "INN-101",
        "teacher": "Prof. Coordenador",
        "hours": 60,
        "status": "active",
        "created_at": datetime.datetime.now().isoformat()
    },
    {
        "id": 2,
        "name": "Inteligência Artificial Aplicada",
        "code": "IA-201",
        "teacher": "Dra. Ana Silva",
        "hours": 80,
        "status": "active",
        "created_at": datetime.datetime.now().isoformat()
    }
]

# In-memory storage for non-streamlit environments (e.g. CLI tests)
_in_memory_subjects: List[Dict[str, Any]] = [dict(s) for s in INITIAL_SUBJECTS]


def _get_storage() -> List[Dict[str, Any]]:
    if st is not None and hasattr(st, "session_state"):
        if "subjects" not in st.session_state:
            st.session_state["subjects"] = [dict(s) for s in INITIAL_SUBJECTS]
        return st.session_state["subjects"]
    return _in_memory_subjects


def is_xano_configured() -> bool:
    return bool(os.getenv("XANO_API_URL"))


def get_subjects() -> List[Dict[str, Any]]:
    """Fetch all subjects from Xano if configured, otherwise from session state."""
    api_url = os.getenv("XANO_API_URL")
    if api_url and requests is not None:
        try:
            headers = {}
            api_key = os.getenv("XANO_API_KEY")
            if api_key:
                headers["Authorization"] = f"Bearer {api_key}"
            response = requests.get(f"{api_url.rstrip('/')}/subjects", headers=headers, timeout=5)
            if response.status_code == 200:
                return response.json()
        except Exception:
            pass

    return _get_storage()


def create_subject(
    name: str,
    code: str = "",
    teacher: str = "",
    hours: Optional[int] = None,
    professor: str = "",
    workload_hours: Optional[int] = None,
    status: str = "active",
    user_id: Optional[int] = None
) -> Dict[str, Any]:
    """Create a new subject with validation matching subjects table schema."""
    clean_name = (name or "").strip()
    if not clean_name:
        raise ValueError("O nome da disciplina é obrigatório.")

    instructor = (teacher or professor or "").strip()
    workload = hours if hours is not None else (workload_hours if workload_hours is not None else 0)

    subject_data = {
        "name": clean_name,
        "code": (code or "").strip(),
        "teacher": instructor,
        "professor": instructor,
        "hours": workload,
        "workload_hours": workload,
        "status": status if status in ("active", "archived") else "active",
        "user_id": user_id,
        "created_at": datetime.datetime.now().isoformat()
    }

    api_url = os.getenv("XANO_API_URL")
    if api_url and requests is not None:
        try:
            headers = {}
            api_key = os.getenv("XANO_API_KEY")
            if api_key:
                headers["Authorization"] = f"Bearer {api_key}"
            response = requests.post(f"{api_url.rstrip('/')}/subjects", json=subject_data, headers=headers, timeout=5)
            if response.status_code in (200, 201):
                return response.json()
        except Exception:
            pass

    storage = _get_storage()
    new_id = max([s.get("id", 0) for s in storage], default=0) + 1
    subject_data["id"] = new_id
    storage.append(subject_data)
    return subject_data


def toggle_subject_status(subject_id: int) -> Optional[Dict[str, Any]]:
    """Toggle subject status between active and archived."""
    storage = _get_storage()
    for s in storage:
        if s.get("id") == subject_id:
            current_status = s.get("status", "active")
            s["status"] = "archived" if current_status == "active" else "active"
            return s
    return None


def count_active_subjects() -> int:
    """Return count of active subjects."""
    subjects = get_subjects()
    return sum(1 for s in subjects if s.get("status") == "active")
