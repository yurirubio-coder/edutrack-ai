"""
Student Performance Report Generation Script for EduTrack AI.

Fetches academic subjects and tasks from the Xano backend endpoints
and generates a formatted PDF performance report summarizing student progress.
"""

import argparse
import datetime
import json
import os
import sys
import urllib.error
import urllib.request
from typing import Any, Dict, List, Optional, Tuple

# Default Xano API endpoint configuration
DEFAULT_BASE_URL = os.getenv("EDUTRACK_API_BASE_URL", "https://x8ki-letl-twmt.n7.xano.io/api:ILKDtEV0")
COMPLETED_STATUSES = {"completed", "concluida", "concluída", "done"}


def fetch_from_endpoint(
    endpoint: str,
    base_url: str = DEFAULT_BASE_URL,
    auth_token: Optional[str] = None,
) -> List[Dict[str, Any]]:
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
                raise RuntimeError(f"Failed to fetch data from {url}: HTTP status {response.status}")
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Network error accessing endpoint {url}: {exc}") from exc


def fetch_subjects(base_url: str = DEFAULT_BASE_URL, auth_token: Optional[str] = None) -> List[Dict[str, Any]]:
    """Fetch all subjects for the authenticated user from the backend API."""
    return fetch_from_endpoint("subjects", base_url=base_url, auth_token=auth_token)


def fetch_academic_tasks(base_url: str = DEFAULT_BASE_URL, auth_token: Optional[str] = None) -> List[Dict[str, Any]]:
    """Fetch all academic tasks for the authenticated user from the backend API."""
    return fetch_from_endpoint("academic_tasks", base_url=base_url, auth_token=auth_token)


def fetch_report_data(
    base_url: str = DEFAULT_BASE_URL,
    auth_token: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """
    Fetch student data from the Xano GET /student_performance_report endpoint.
    If unavailable, falls back to separate subjects and academic_tasks endpoints.
    """
    try:
        data = fetch_from_endpoint("student_performance_report", base_url=base_url, auth_token=auth_token)
        target = data[0] if (isinstance(data, list) and len(data) > 0 and isinstance(data[0], dict)) else data
        if isinstance(target, dict) and ("subjects" in target or "academic_tasks" in target):
            return target.get("subjects", []), target.get("academic_tasks", [])
    except Exception:
        pass

    subjects = fetch_subjects(base_url=base_url, auth_token=auth_token)
    tasks = fetch_academic_tasks(base_url=base_url, auth_token=auth_token)
    return subjects, tasks


def calculate_student_performance(
    subjects: List[Dict[str, Any]],
    tasks: List[Dict[str, Any]],
) -> Dict[str, Any]:
    """
    Calculate summary performance metrics and breakdown by subject.

    :param subjects: List of student subject dictionaries.
    :param tasks: List of student academic task dictionaries.
    :return: Dictionary containing consolidated performance metrics.
    """
    subject_map = {s.get("id"): s for s in subjects if s.get("id") is not None}

    total_tasks = len(tasks)
    completed_tasks = 0
    pending_tasks = 0

    # Subject aggregation
    subject_stats: Dict[int, Dict[str, Any]] = {}
    for sub_id, sub_data in subject_map.items():
        subject_stats[sub_id] = {
            "id": sub_id,
            "name": sub_data.get("name") or "Unnamed Subject",
            "code": sub_data.get("code") or "-",
            "total_tasks": 0,
            "completed_tasks": 0,
            "pending_tasks": 0,
            "progress_percentage": 0.0,
            "tasks": [],
        }

    # Unknown subject bucket
    unassigned_tasks: List[Dict[str, Any]] = []

    for task in tasks:
        raw_status = str(task.get("status", "")).strip().lower()
        is_completed = raw_status in COMPLETED_STATUSES

        if is_completed:
            completed_tasks += 1
        else:
            pending_tasks += 1

        sub_id = task.get("subject_id")
        if sub_id in subject_stats:
            stats = subject_stats[sub_id]
            stats["total_tasks"] += 1
            if is_completed:
                stats["completed_tasks"] += 1
            else:
                stats["pending_tasks"] += 1
            stats["tasks"].append(task)
        else:
            unassigned_tasks.append(task)

    # Compute percentage per subject
    for stats in subject_stats.values():
        if stats["total_tasks"] > 0:
            stats["progress_percentage"] = round((stats["completed_tasks"] / stats["total_tasks"]) * 100.0, 1)
        else:
            stats["progress_percentage"] = 0.0

    # Overall progress
    if total_tasks > 0:
        overall_progress = round((completed_tasks / total_tasks) * 100.0, 1)
    else:
        overall_progress = 0.0

    return {
        "generated_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "total_subjects": len(subjects),
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "pending_tasks": pending_tasks,
        "overall_progress_percentage": overall_progress,
        "subjects": list(subject_stats.values()),
        "unassigned_tasks": unassigned_tasks,
        "all_tasks": tasks,
    }


def _escape_pdf_text(text: str) -> str:
    """Escape special characters for standard PDF string literals."""
    return (
        text.replace("\\", "\\\\")
        .replace("(", "\\(")
        .replace(")", "\\)")
        .encode("latin-1", "replace")
        .decode("latin-1")
    )


def generate_pdf_with_cairo(performance_data: Dict[str, Any], output_path: str) -> bool:
    """
    Attempt to render a professional PDF report using Cairo vector graphics.
    Returns True on success, False if Cairo is unavailable.
    """
    try:
        import cairo
    except ImportError:
        return False

    width, height = 595.0, 842.0  # Standard A4 size in points
    surface = cairo.PDFSurface(output_path, width, height)
    ctx = cairo.Context(surface)

    # Background header banner
    ctx.set_source_rgb(0.08, 0.38, 0.74)  # EduTrack Primary Blue
    ctx.rectangle(0, 0, width, 110)
    ctx.fill()

    # Title
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(24)
    ctx.move_to(40, 50)
    ctx.show_text("EduTrack AI")

    ctx.set_font_size(14)
    ctx.move_to(40, 75)
    ctx.show_text("Student Academic Performance Report")

    ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    ctx.set_font_size(10)
    ctx.move_to(40, 95)
    ctx.show_text(f"Generated on: {performance_data.get('generated_at', '-')}")

    # Summary Metrics Cards
    y_summary = 140
    card_width = 115
    card_height = 65
    gap = 15
    start_x = 40

    cards = [
        ("Overall Progress", f"{performance_data['overall_progress_percentage']}%", (0.1, 0.6, 0.3)),
        ("Subjects", str(performance_data["total_subjects"]), (0.2, 0.4, 0.7)),
        ("Total Tasks", str(performance_data["total_tasks"]), (0.3, 0.3, 0.3)),
        ("Completed", str(performance_data["completed_tasks"]), (0.1, 0.6, 0.3)),
    ]

    for i, (label, val, color) in enumerate(cards):
        cx = start_x + i * (card_width + gap)
        # Card Background
        ctx.set_source_rgb(0.95, 0.96, 0.98)
        ctx.rectangle(cx, y_summary, card_width, card_height)
        ctx.fill()

        # Border
        ctx.set_source_rgb(0.85, 0.88, 0.92)
        ctx.set_line_width(1)
        ctx.rectangle(cx, y_summary, card_width, card_height)
        ctx.stroke()

        # Card value
        ctx.set_source_rgb(*color)
        ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        ctx.set_font_size(18)
        ctx.move_to(cx + 12, y_summary + 32)
        ctx.show_text(val)

        # Card label
        ctx.set_source_rgb(0.4, 0.45, 0.5)
        ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
        ctx.set_font_size(9)
        ctx.move_to(cx + 12, y_summary + 52)
        ctx.show_text(label)

    # Section 1: Subject Performance Breakdown
    y_pos = 240
    ctx.set_source_rgb(0.15, 0.2, 0.3)
    ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(13)
    ctx.move_to(40, y_pos)
    ctx.show_text("Performance by Subject")

    y_pos += 15
    # Table Header
    ctx.set_source_rgb(0.9, 0.92, 0.95)
    ctx.rectangle(40, y_pos, 515, 22)
    ctx.fill()

    ctx.set_source_rgb(0.2, 0.25, 0.3)
    ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(9)
    ctx.move_to(50, y_pos + 15)
    ctx.show_text("Subject")
    ctx.move_to(220, y_pos + 15)
    ctx.show_text("Code")
    ctx.move_to(320, y_pos + 15)
    ctx.show_text("Tasks (Done/Total)")
    ctx.move_to(460, y_pos + 15)
    ctx.show_text("Progress")

    y_pos += 24
    ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)

    subjects_list = performance_data.get("subjects", [])
    if not subjects_list:
        ctx.set_source_rgb(0.5, 0.5, 0.5)
        ctx.move_to(50, y_pos + 15)
        ctx.show_text("No subjects registered.")
        y_pos += 25
    else:
        for sub in subjects_list:
            ctx.set_source_rgb(0.2, 0.2, 0.2)
            ctx.move_to(50, y_pos + 14)
            name = (sub.get("name") or "")[:30]
            ctx.show_text(name)
            ctx.move_to(220, y_pos + 14)
            ctx.show_text(sub.get("code") or "-")
            ctx.move_to(320, y_pos + 14)
            ctx.show_text(f"{sub.get('completed_tasks', 0)} / {sub.get('total_tasks', 0)}")
            ctx.move_to(460, y_pos + 14)
            ctx.show_text(f"{sub.get('progress_percentage', 0.0)}%")

            y_pos += 20
            if y_pos > height - 120:
                break

    # Section 2: Task Summary
    y_pos += 20
    if y_pos < height - 120:
        ctx.set_source_rgb(0.15, 0.2, 0.3)
        ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        ctx.set_font_size(13)
        ctx.move_to(40, y_pos)
        ctx.show_text("Recent Academic Tasks")

        y_pos += 15
        ctx.set_source_rgb(0.9, 0.92, 0.95)
        ctx.rectangle(40, y_pos, 515, 22)
        ctx.fill()

        ctx.set_source_rgb(0.2, 0.25, 0.3)
        ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        ctx.set_font_size(9)
        ctx.move_to(50, y_pos + 15)
        ctx.show_text("Task Title")
        ctx.move_to(320, y_pos + 15)
        ctx.show_text("Due Date")
        ctx.move_to(460, y_pos + 15)
        ctx.show_text("Status")

        y_pos += 24
        ctx.select_font_face("Helvetica", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
        all_tasks = performance_data.get("all_tasks", [])
        if not all_tasks:
            ctx.set_source_rgb(0.5, 0.5, 0.5)
            ctx.move_to(50, y_pos + 14)
            ctx.show_text("No academic tasks registered.")
            y_pos += 20
        else:
            for task in all_tasks[:10]:
                ctx.set_source_rgb(0.2, 0.2, 0.2)
                ctx.move_to(50, y_pos + 14)
                title = (task.get("title") or "Untitled")[:40]
                ctx.show_text(title)
                ctx.move_to(320, y_pos + 14)
                ctx.show_text(str(task.get("due_date") or "-"))
                ctx.move_to(460, y_pos + 14)
                status = str(task.get("status") or "pending")
                ctx.show_text(status)

                y_pos += 18
                if y_pos > height - 60:
                    break

    # Footer
    ctx.set_source_rgb(0.6, 0.65, 0.7)
    ctx.set_font_size(8)
    ctx.move_to(40, height - 30)
    ctx.show_text("EduTrack AI Academic Management Platform — Confidential & Internal Use Only")

    surface.finish()
    return True


def generate_pdf_pure_python(performance_data: Dict[str, Any], output_path: str) -> None:
    """
    Standard-compliant PDF 1.4 generator implemented in pure Python.
    Produces a valid, formatted PDF report without external dependencies.
    """
    objects: List[str] = []

    def add_object(body: str) -> int:
        objects.append(body)
        return len(objects)

    # 1. Catalog
    add_object("<< /Type /Catalog /Pages 2 0 R >>")
    # 2. Pages collection
    add_object("<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
    # 3. Page definition
    add_object(
        "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] "
        "/Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> "
        "/Contents 6 0 R >>"
    )
    # 4. Normal font
    add_object("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
    # 5. Bold font
    add_object("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>")

    # Build stream commands for PDF contents
    stream: List[str] = []

    # Blue header banner
    stream.append("0.08 0.38 0.74 rg")
    stream.append("0 732 595 110 re f")

    # Header title text
    stream.append("1.0 1.0 1.0 rg")
    stream.append("BT /F2 22 Tf 40 800 Td (EduTrack AI) Tj ET")
    stream.append("BT /F2 13 Tf 40 778 Td (Student Academic Performance Report) Tj ET")
    gen_at = _escape_pdf_text(str(performance_data.get("generated_at", "-")))
    stream.append(f"BT /F1 10 Tf 40 758 Td (Generated on: {gen_at}) Tj ET")

    # Executive Summary Card Boxes
    stream.append("0.95 0.96 0.98 rg")
    stream.append("40 650 515 65 re f")
    stream.append("0.80 0.84 0.90 RG 1 w")
    stream.append("40 650 515 65 re S")

    # Card Metrics
    stream.append("0.15 0.20 0.30 rg")
    stream.append("BT /F2 11 Tf 55 695 Td (Overall Progress) Tj ET")
    stream.append(
        f"BT /F2 16 Tf 55 670 Td ({performance_data['overall_progress_percentage']}%) Tj ET"
    )

    stream.append("BT /F2 11 Tf 185 695 Td (Subjects) Tj ET")
    stream.append(
        f"BT /F2 16 Tf 185 670 Td ({performance_data['total_subjects']}) Tj ET"
    )

    stream.append("BT /F2 11 Tf 305 695 Td (Total Tasks) Tj ET")
    stream.append(
        f"BT /F2 16 Tf 305 670 Td ({performance_data['total_tasks']}) Tj ET"
    )

    stream.append("BT /F2 11 Tf 425 695 Td (Completed) Tj ET")
    stream.append(
        f"BT /F2 16 Tf 425 670 Td ({performance_data['completed_tasks']}) Tj ET"
    )

    # Section 1: Subject breakdown
    stream.append("0.10 0.15 0.25 rg")
    stream.append("BT /F2 13 Tf 40 615 Td (Performance by Subject) Tj ET")

    # Table Header
    stream.append("0.90 0.92 0.95 rg")
    stream.append("40 590 515 20 re f")
    stream.append("0.20 0.25 0.35 rg")
    stream.append("BT /F2 9 Tf 50 596 Td (Subject) Tj ET")
    stream.append("BT /F2 9 Tf 220 596 Td (Code) Tj ET")
    stream.append("BT /F2 9 Tf 320 596 Td (Tasks (Done/Total)) Tj ET")
    stream.append("BT /F2 9 Tf 460 596 Td (Progress) Tj ET")

    y_pos = 572
    subjects_list = performance_data.get("subjects", [])
    if not subjects_list:
        stream.append("0.5 0.5 0.5 rg")
        stream.append(f"BT /F1 9 Tf 50 {y_pos} Td (No subjects registered.) Tj ET")
        y_pos -= 20
    else:
        for sub in subjects_list[:8]:
            stream.append("0.15 0.15 0.15 rg")
            name = _escape_pdf_text((sub.get("name") or "")[:28])
            code = _escape_pdf_text((sub.get("code") or "-")[:12])
            tasks_str = _escape_pdf_text(f"{sub.get('completed_tasks', 0)} / {sub.get('total_tasks', 0)}")
            prog_str = _escape_pdf_text(f"{sub.get('progress_percentage', 0.0)}%")

            stream.append(f"BT /F1 9 Tf 50 {y_pos} Td ({name}) Tj ET")
            stream.append(f"BT /F1 9 Tf 220 {y_pos} Td ({code}) Tj ET")
            stream.append(f"BT /F1 9 Tf 320 {y_pos} Td ({tasks_str}) Tj ET")
            stream.append(f"BT /F1 9 Tf 460 {y_pos} Td ({prog_str}) Tj ET")
            y_pos -= 18

    # Section 2: Tasks table
    y_pos -= 15
    if y_pos > 150:
        stream.append("0.10 0.15 0.25 rg")
        stream.append(f"BT /F2 13 Tf 40 {y_pos} Td (Recent Academic Tasks) Tj ET")
        y_pos -= 20

        stream.append("0.90 0.92 0.95 rg")
        stream.append(f"40 {y_pos} 515 20 re f")
        stream.append("0.20 0.25 0.35 rg")
        stream.append(f"BT /F2 9 Tf 50 {y_pos + 6} Td (Task Title) Tj ET")
        stream.append(f"BT /F2 9 Tf 320 {y_pos + 6} Td (Due Date) Tj ET")
        stream.append(f"BT /F2 9 Tf 460 {y_pos + 6} Td (Status) Tj ET")
        y_pos -= 18

        all_tasks = performance_data.get("all_tasks", [])
        if not all_tasks:
            stream.append("0.5 0.5 0.5 rg")
            stream.append(f"BT /F1 9 Tf 50 {y_pos} Td (No tasks registered.) Tj ET")
        else:
            for task in all_tasks[:10]:
                if y_pos < 60:
                    break
                stream.append("0.15 0.15 0.15 rg")
                title = _escape_pdf_text((task.get("title") or "Untitled")[:38])
                due = _escape_pdf_text(str(task.get("due_date") or "-"))
                st_str = _escape_pdf_text(str(task.get("status") or "pending"))

                stream.append(f"BT /F1 9 Tf 50 {y_pos} Td ({title}) Tj ET")
                stream.append(f"BT /F1 9 Tf 320 {y_pos} Td ({due}) Tj ET")
                stream.append(f"BT /F1 9 Tf 460 {y_pos} Td ({st_str}) Tj ET")
                y_pos -= 16

    # Footer note
    stream.append("0.55 0.60 0.65 rg")
    stream.append("BT /F1 8 Tf 40 30 Td (EduTrack AI Academic Management Platform -- Confidential) Tj ET")

    stream_content = "\n".join(stream).encode("latin-1", "replace")
    add_object(
        f"<< /Length {len(stream_content)} >>\nstream\n"
        + stream_content.decode("latin-1")
        + "\nendstream"
    )

    # Assembly
    raw_lines = ["%PDF-1.4\n"]
    offsets = [0]
    cursor = len(raw_lines[0].encode("latin-1"))

    for idx, obj_body in enumerate(objects, 1):
        offsets.append(cursor)
        block = f"{idx} 0 obj\n{obj_body}\nendobj\n"
        raw_lines.append(block)
        cursor += len(block.encode("latin-1"))

    xref_pos = cursor
    raw_lines.append(f"xref\n0 {len(objects) + 1}\n0000000000 65535 f \n")
    for off in offsets[1:]:
        raw_lines.append(f"{off:010d} 00000 n \n")

    raw_lines.append(
        f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref_pos}\n%%EOF\n"
    )

    with open(output_path, "wb") as f:
        f.write("".join(raw_lines).encode("latin-1"))


def generate_performance_report_pdf(
    performance_data: Dict[str, Any],
    output_path: str,
) -> str:
    """
    Generate PDF report from performance data, utilizing Cairo when available
    or falling back to pure Python rendering.
    """
    # Attempt with Cairo first
    cairo_ok = False
    try:
        cairo_ok = generate_pdf_with_cairo(performance_data, output_path)
    except Exception:
        cairo_ok = False

    if not cairo_ok:
        generate_pdf_pure_python(performance_data, output_path)

    return os.path.abspath(output_path)


def main() -> None:
    """Command-line entry point for generating the student performance report PDF."""
    parser = argparse.ArgumentParser(
        description="Generate a PDF performance report for student academic records in EduTrack AI."
    )
    parser.add_argument(
        "--output",
        "-o",
        type=str,
        default="relatorio_desempenho.pdf",
        help="Target path for generated PDF file",
    )
    parser.add_argument(
        "--base-url",
        type=str,
        default=DEFAULT_BASE_URL,
        help="Base URL for backend API",
    )
    parser.add_argument(
        "--auth-token",
        type=str,
        default=os.getenv("EDUTRACK_AUTH_TOKEN"),
        help="Bearer authentication token",
    )
    parser.add_argument(
        "--subjects-file",
        type=str,
        help="Optional local JSON file with subjects for offline execution",
    )
    parser.add_argument(
        "--tasks-file",
        type=str,
        help="Optional local JSON file with tasks for offline execution",
    )

    args = parser.parse_args()

    subjects_data: List[Dict[str, Any]] = []
    tasks_data: List[Dict[str, Any]] = []

    try:
        # Load subjects and tasks
        if args.subjects_file:
            with open(args.subjects_file, "r", encoding="utf-8") as f:
                subjects_data = json.load(f)
        if args.tasks_file:
            with open(args.tasks_file, "r", encoding="utf-8") as f:
                tasks_data = json.load(f)

        if not args.subjects_file and not args.tasks_file and args.auth_token:
            subjects_data, tasks_data = fetch_report_data(base_url=args.base_url, auth_token=args.auth_token)
        elif not args.subjects_file and args.auth_token:
            subjects_data = fetch_subjects(base_url=args.base_url, auth_token=args.auth_token)
        elif not args.tasks_file and args.auth_token:
            tasks_data = fetch_academic_tasks(base_url=args.base_url, auth_token=args.auth_token)

        # Compute metrics
        performance = calculate_student_performance(subjects_data, tasks_data)

        # Generate report PDF
        pdf_path = generate_performance_report_pdf(performance, args.output)

        result = {
            "status": "success",
            "pdf_path": pdf_path,
            "overall_progress_percentage": performance["overall_progress_percentage"],
            "total_subjects": performance["total_subjects"],
            "total_tasks": performance["total_tasks"],
            "completed_tasks": performance["completed_tasks"],
        }
        print(json.dumps(result, indent=2, ensure_ascii=False))

    except Exception as exc:
        err_result = {"status": "error", "error": str(exc)}
        print(json.dumps(err_result, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
