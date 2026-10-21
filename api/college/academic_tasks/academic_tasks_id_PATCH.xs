// Update academic_tasks record for authenticated user
query "academic_tasks/{academic_task_id}" verb=PATCH {
  api_group = "College"
  auth = "user"

  input {
    int academic_task_id filters=min:1
    text? title? filters=trim
    text? description? filters=trim
    date? due_date?
    text? status? filters=trim
    int? subject_id?
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

    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input

    db.patch academic_tasks {
      field_name = "id"
      field_value = $input.academic_task_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $updated_task
  }

  response = $updated_task
  guid = "Qvg_lb3OBeEg4E5FqgbsieDWJXk"
}

