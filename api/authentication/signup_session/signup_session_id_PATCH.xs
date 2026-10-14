// Edit signup_session record
query "signup_session/{signup_session_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int signup_session_id? filters=min:1
    dblink {
      table = "signup_session"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch signup_session {
      field_name = "id"
      field_value = $input.signup_session_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $signup_session
  }

  response = $signup_session
  guid = "ks_1WzQldnpjO7pZzix7KGl7gq8"
}