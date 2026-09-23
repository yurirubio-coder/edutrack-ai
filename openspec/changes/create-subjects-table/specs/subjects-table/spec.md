# Spec Delta

## Purpose

Defines the database schema specification for the subjects table in Xano, establishing the structure and relational foreign keys for student coursework records.

## ADDED Requirements

### Requirement: Subjects Table Schema
The system SHALL define a database table named `subjects` with columns `id`, `name`, `teacher`, `hours`, and `user_id`.

#### Scenario: Verify schema fields
- **WHEN** the `subjects.xs` schema definition is inspected
- **THEN** it contains `id` (int primary key), `name` (text), `teacher` (text), `hours` (int), and `user_id` (int foreign key to `user`)

### Requirement: User Authentication Foreign Key Reference
The system SHALL establish a relational foreign key constraint linking `subjects.user_id` to the Xano authentication table `user`.

#### Scenario: Verify foreign key binding
- **WHEN** the `user_id` field is evaluated in the schema
- **THEN** it declares a reference table configuration pointing to `user`

