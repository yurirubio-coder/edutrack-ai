// Delete signup_session record.
query "signup_session/{signup_session_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int signup_session_id? filters=min:1
  }

  stack {
    db.del signup_session {
      field_name = "id"
      field_value = $input.signup_session_id
    }
  }

  response = null
  guid = "dZcjOSI7jxtZlySNkOPWPxB2onE"
}