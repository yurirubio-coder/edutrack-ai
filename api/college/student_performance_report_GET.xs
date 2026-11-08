// Get student performance report data and academic summary for authenticated user
query student_performance_report verb=GET {
  api_group = "College"
  auth = "user"

  input {
  }

  stack {
    db.query subjects {
      where = $db.subjects.user_id == $auth.id
      return = {type: "list"}
    } as $subjects

    db.query academic_tasks {
      where = $db.academic_tasks.user_id == $auth.id
      return = {type: "list"}
    } as $academic_tasks
  }

  response = {
    user_id       : $auth.id
    subjects      : $subjects
    academic_tasks: $academic_tasks
  }
}
