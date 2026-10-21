"""
Academic Progress Calculation Script for EduTrack AI.

Calculates the completion percentage of academic tasks for a given subject
by consuming the existing CRUD endpoints, returning structured JSON metrics.
"""

import json
import os
import sys
import argparse
from typing import Any, Dict, List, Optional
import urllib.request
import urllib.error

# Default Xano API endpoint configuration
DEFAULT_BASE_URL = os.getenv("EDUTRACK_API_BASE_URL", "https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0")
COMPLETED_STATUSES = {"completed", "concluida", "concluída", "done"}


def fetch_from_endpoint(endpoint: str, base_url: str = DEFAULT_BASE_URL, auth_token: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Fetch records from a CRUD endpoint using HTTP GET.

    :param endpoint: Relative endpoint path (e.g., 'academic_tasks' or 'subjects').
    :param base_url: Base API URL.
    :param auth_token: Optional Bearer authentication token.
    :return: List of record dictionaries.
    """
    clean_base = base_url.rstrip("/")
    clean_endpoint = endpoint.lstrip("/")
    url = f"{clean_base}/{clean_endpoint}"

    req = urllib.request.Request(url, method="GET")
    req.add_header("Accept", "application/json")
    if auth_token:
        req.add_header("Authorization", f"Bearer {auth_token}")

    try:
        with urllib.request.urlopen(req) as response:
            if response.status == 200:
                data = json.loads(response.read().decode("utf-8"))
                if isinstance(data, list):
                    return data
                elif isinstance(data, dict) and "response" in data:
                    return data["response"]
                return [data]
            else:
                raise RuntimeError(f"Failed to fetch data from {url}: status {response.status}")
    except urllib.error.URLError as e:
        raise RuntimeError(f"Error accessing endpoint {url}: {e}")


def fetch_academic_tasks(base_url: str = DEFAULT_BASE_URL, auth_token: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Fetch all academic tasks for the authenticated user from the CRUD API.

    :param base_url: Base API URL.
    :param auth_token: Optional Bearer authentication token.
    :return: List of academic tasks.
    """
    return fetch_from_endpoint("academic_tasks", base_url=base_url, auth_token=auth_token)


def fetch_subjects(base_url: str = DEFAULT_BASE_URL, auth_token: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Fetch all subjects for the authenticated user from the CRUD API.

    :param base_url: Base API URL.
    :param auth_token: Optional Bearer authentication token.
    :return: List of subjects.
    """
    return fetch_from_endpoint("subjects", base_url=base_url, auth_token=auth_token)


def calculate_progress(
    subject_id: int,
    tasks: Optional[List[Dict[str, Any]]] = None,
    base_url: str = DEFAULT_BASE_URL,
    auth_token: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Calculate progress percentage for a subject based on its academic tasks.

    :param subject_id: ID of the subject to calculate progress for.
    :param tasks: Optional pre-fetched task list. If None, tasks are fetched via CRUD endpoint.
    :param base_url: Base URL for CRUD API if tasks need to be fetched.
    :param auth_token: Auth token for API access if tasks need to be fetched.
    :return: Dictionary containing subject_id, total_tasks, completed_tasks,
             pending_tasks, and progress_percentage.
    """
    if tasks is None:
        tasks = fetch_academic_tasks(base_url=base_url, auth_token=auth_token)

    # Filter tasks associated with the specific subject
    subject_tasks = [task for task in tasks if task.get("subject_id") == subject_id]

    total_tasks = len(subject_tasks)
    completed_tasks = sum(
        1 for task in subject_tasks
        if str(task.get("status", "")).strip().lower() in COMPLETED_STATUSES
    )
    pending_tasks = total_tasks - completed_tasks

    # Calculate percentage with division-by-zero protection
    if total_tasks == 0:
        progress_percentage = 0.0
    else:
        progress_percentage = round((completed_tasks / total_tasks) * 100.0, 2)

    return {
        "subject_id": subject_id,
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "pending_tasks": pending_tasks,
        "progress_percentage": progress_percentage,
    }


def calculate_progress_json(
    subject_id: int,
    tasks: Optional[List[Dict[str, Any]]] = None,
    base_url: str = DEFAULT_BASE_URL,
    auth_token: Optional[str] = None,
    indent: int = 2,
) -> str:
    """
    Calculate progress and return a formatted JSON string.

    :param subject_id: ID of the subject.
    :param tasks: Optional task list.
    :param base_url: Base API URL.
    :param auth_token: Bearer auth token.
    :param indent: JSON indentation spacing.
    :return: Formatted JSON string.
    """
    result = calculate_progress(
        subject_id=subject_id,
        tasks=tasks,
        base_url=base_url,
        auth_token=auth_token,
    )
    return json.dumps(result, indent=indent, ensure_ascii=False)


def main() -> None:
    """Command-line interface entry point for progress calculation."""
    parser = argparse.ArgumentParser(description="Calculate subject progress from academic tasks in EduTrack AI.")
    parser.add_argument("--subject-id", type=int, required=True, help="Subject ID to calculate progress for")
    parser.add_argument("--base-url", type=str, default=DEFAULT_BASE_URL, help="Base API URL for CRUD endpoints")
    parser.add_argument("--auth-token", type=str, default=os.getenv("EDUTRACK_AUTH_TOKEN"), help="Bearer auth token")
    parser.add_argument("--tasks-file", type=str, help="Optional local JSON file with tasks to calculate offline")

    args = parser.parse_args()

    tasks_data = None
    if args.tasks_file:
        with open(args.tasks_file, "r", encoding="utf-8") as f:
            tasks_data = json.load(f)

    try:
        output_json = calculate_progress_json(
            subject_id=args.subject_id,
            tasks=tasks_data,
            base_url=args.base_url,
            auth_token=args.auth_token,
        )
        print(output_json)
    except Exception as exc:
        print(json.dumps({"error": str(exc)}), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

