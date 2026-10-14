// Get signup_session record
query "signup_session/{signup_session_id}" verb=GET {
  api_group = "Authentication"

  input {
    int signup_session_id? filters=min:1
  }

  stack {
    db.get signup_session {
      field_name = "id"
      field_value = $input.signup_session_id
    } as $signup_session
  
    precondition ($signup_session != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $signup_session
  guid = "VsGH90LUGYdBqzl-EFxzF2u0sX4"
}