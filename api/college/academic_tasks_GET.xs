// Query academic_tasks records for authenticated user
query academic_tasks verb=GET {
  api_group = "College"
  auth = "user"

  input {
  }

  stack {
    db.query academic_tasks {
      where = $db.academic_tasks.user_id == $auth.id
      return = {type: "list"}
    } as $academic_tasks
  }

  response = $academic_tasks
  guid = "qWkkppdhrzseZjHStvs4zE-ZAvs"
}

