// Update subjects record for authenticated user
query "subjects/{subjects_id}" verb=PATCH {
  api_group = "College"
  auth = "user"

  input {
    int subjects_id filters=min:1
    text? name? filters=trim
    text? description? filters=trim
    text? code? filters=trim
  }

  stack {
    db.get subjects {
      field_name = "id"
      field_value = $input.subjects_id
    } as $subject

    precondition ($subject != null && $subject.user_id == $auth.id) {
      error_type = "notfound"
      error = "Subject not found."
    }

    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input

    db.patch subjects {
      field_name = "id"
      field_value = $input.subjects_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $updated_subject
  }

  response = $updated_subject
  guid = "sGxCBdfVzy1x4ov4KWo9t9IQjg4"
}

