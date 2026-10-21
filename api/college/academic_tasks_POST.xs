// Add academic_tasks record for authenticated user
query academic_tasks verb=POST {
  api_group = "College"
  auth = "user"

  input {
    text title filters=trim
    text? description? filters=trim
    date? due_date?
    text status?=pending
    int? subject_id?
  }

  stack {
    db.add academic_tasks {
      data = {
        title      : $input.title
        description: $input.description
        due_date   : $input.due_date
        status     : $input.status
        subject_id : $input.subject_id
        user_id    : $auth.id
        created_at : "now"
      }
    } as $academic_task
  }

  response = $academic_task
  guid = "6Bklvt0NZGr1Wp6W8ftq0hP3-_s"
}

