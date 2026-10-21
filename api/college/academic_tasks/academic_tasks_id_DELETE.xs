// Delete academic_tasks record for authenticated user
query "academic_tasks/{academic_task_id}" verb=DELETE {
  api_group = "College"
  auth = "user"

  input {
    int academic_task_id filters=min:1
  }

  stack {
    db.get academic_tasks {
      field_name = "id"
      field_value = $input.academic_task_id
    } as $task

    precondition ($task != null && $task.user_id == $auth.id) {
      error_type = "notfound"
      error = "Academic task not found."
    }

    db.del academic_tasks {
      field_name = "id"
      field_value = $input.academic_task_id
    }
  }

  response = null
  guid = "65o6vPHcl9rHbt2PgyyjrSqidTw"
}

