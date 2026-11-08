## Context

EduTrack AI tracks academic activities and subjects for students. To facilitate academic monitoring, students need an exportable performance report in PDF format. This change introduces an automated Python script to generate the report and an authenticated Xano backend endpoint to download the resulting PDF file.

## Goals / Non-Goals

**Goals:**
- Provide a Python script (`scripts/generate_performance_report.py`) that fetches student subjects and academic tasks to compute performance metrics and generate a PDF report.
- Provide a Xano REST endpoint (`GET /student_performance_report`) under the `College` API group that securely serves the report file for the authenticated student.

**Non-Goals:**
- Modifying or adding Streamlit user interface components (not requested).
- Automated email dispatch or scheduling of reports (not requested).
- Editing or deleting generated PDF reports via API (not requested).
- Database table modifications or additions (existing schema contains required academic records).

## Decisions

- **Python PDF Generator**: Implement `scripts/generate_performance_report.py` using Python's standard formatting or lightweight PDF library, querying existing student academic tasks and subjects, and outputting a structured PDF file.
- **Backend Endpoint Structure**: Place `student_performance_report_GET.xs` under API group `College` (`canonical = "ILKDtEV0"`), requiring `auth = "user"` and enforcing filtering by authenticated user ID (`$auth.id`).
- **Data Isolation**: Ensure all queries strictly filter by `user_id == $auth.id` according to project security rules.

## Risks / Trade-offs

- [Risk: PDF generation dependency requirements] → Mitigation: Use standard, lightweight PDF generation libraries compatible with Python 3.10+ and document dependencies in `requirements.txt`.
- [Risk: Formatting for students with extensive task lists] → Mitigation: Design the report layout with clear tabular sections, page-breaking or summarization by subject.
