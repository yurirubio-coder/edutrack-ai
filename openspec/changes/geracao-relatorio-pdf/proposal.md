## Why

Students need a portable and exportable document (PDF) detailing their academic performance, including enrolled subjects, task completion status, and overall progress metrics. EduTrack AI currently manages subjects and academic tasks, but lacks an automated Python script to compile and format this performance data into a PDF report, as well as an authenticated Xano backend endpoint to serve and download the resulting file.

## What Changes

- Create a Python script `scripts/generate_performance_report.py` to aggregate student academic records (subjects, academic tasks, completion status) and generate a student performance report in PDF format.
- Create a Xano API endpoint `GET /student_performance_report` under the `College` API group allowing authenticated students to download their PDF performance report file.
- Implement frontend interface in `pages/3_Files.py` allowing authenticated students to preview their academic metrics and download the PDF performance report.
- Provide a quick export option for the PDF performance report in the tasks page (`pages/2_Tarefas.py`).

## Capabilities

### New Capabilities
- `student-performance-report`: Generation of student academic performance reports in PDF format via a Python script, downloading the report file via an authenticated Xano endpoint, and integrating download capabilities into the frontend UI.

### Modified Capabilities

## Impact

- New script: `scripts/generate_performance_report.py`.
- New Xano API endpoint: `api/college/student_performance_report_GET.xs`.
- Frontend interfaces: `pages/3_Files.py` and `pages/2_Tarefas.py`.
- Authentication: Enforces student data isolation by filtering records by `$auth.id` / `user_id`.
- No modifications required to existing database tables.
