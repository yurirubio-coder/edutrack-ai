# academic-tasks Specification

## Purpose
Defines the database schema and storage structure for managing student academic tasks linked to subjects in EduTrack AI.

## Requirements

### Requirement: Academic tasks table schema
The system SHALL define and persist an `academic_tasks` table containing `title` (text), `description` (text), `due_date` (date), `status` (text), `subject_id` (reference to `subjects`), and `user_id` (reference to `user`).

#### Scenario: Academic task schema definition
- **WHEN** the `academic_tasks` table is inspected
- **THEN** it SHALL contain fields `title`, `description`, `due_date`, `status`, `subject_id`, and `user_id` with appropriate data types and foreign key relationships
