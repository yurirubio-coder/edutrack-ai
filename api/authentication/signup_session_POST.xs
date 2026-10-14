// Add signup_session record
query signup_session verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "signup_session"
    }
  }

  stack {
    db.add signup_session {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $signup_session
  }

  response = $signup_session
  guid = "5exm-x2yD9wkvotrD-WO52CFWkA"
}