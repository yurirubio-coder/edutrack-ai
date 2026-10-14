query "auth/signup/password" verb=POST {
  api_group = "Authentication"

  input {
    text signup_token
    text password {
      sensitive = true
    }
  }

  stack {
    db.query signup_session {
      where = $db.signup_session.token == $input.signup_token
      return = {type: "single"}
    } as $session
  
    precondition ($session != null) {
      error = "Sessão inválida."
    }
  
    precondition ($session.email_verified) {
      error = "E-mail não verificado."
    }
  
    db.edit signup_session {
      field_name = "id"
      field_value = $session.id
      enforce_hidden_fields = false
      data = {password: $input.password}
    } as $updated_session
  }

  response = {success: true}
  guid = "CSiiwrz9dHkyKpKLc6Fijicxv9Y"
}