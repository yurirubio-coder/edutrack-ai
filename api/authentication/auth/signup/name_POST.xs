query "auth/signup/name" verb=POST {
  api_group = "Authentication"

  input {
    text signup_token
    text name
  }

  stack {
    db.query signup_session {
      where = $db.signup_session.token == $input.signup_token
      return = {type: "single"}
    } as $session
  
    precondition ($session != null) {
      error = "Sessão inválida."
    }
  
    db.edit signup_session {
      field_name = "id"
      field_value = $session.id
      enforce_hidden_fields = false
      data = {name: $input.name}
    }
  }

  response = {success: true}
  guid = "8q0lpV0TGH5KbpRHG1vGBrgfPJw"
}