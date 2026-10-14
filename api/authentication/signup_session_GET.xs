// Query all signup_session records
query signup_session verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query signup_session {
      return = {type: "list"}
    } as $signup_session
  }

  response = $signup_session
  guid = "rdILerYAKoxE89Z1fjqSTHILKlw"
}