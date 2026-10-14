## Why

Teachers need to record and assign grades to students for specific activities. Currently, EduTrack AI does not have a mechanism to store or submit activity grades.

## What Changes

- Create `activity_grades` table to store grades assigned to student activities.
- Create API endpoint `POST /activity_grades` to allow teachers to record grades for students on specific activities.

## Capabilities

### New Capabilities
- `activity-grades`: Recording and storing activity grades for students by teachers.

### Modified Capabilities

## Impact

- New table `activity_grades` in the database.
- New REST API endpoint `POST /activity_grades` requiring authenticated user context (`user_id`).

