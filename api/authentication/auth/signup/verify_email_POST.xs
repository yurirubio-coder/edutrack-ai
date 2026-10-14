query "auth/signup/verify-email" verb=POST {
  api_group = "Authentication"

  input {
    text signup_token
    text code
  }

  stack {
    db.query signup_session {
      where = $db.signup_session.token == $input.signup_token
      return = {type: "single"}
    } as $session
  
    precondition ($session != null) {
      error_type = "accessdenied"
      error = "Sessão inválida."
    }
  
    var $now {
      value = "now"|add_secs_to_timestamp:0
    }
  
    precondition ($session.expiration > $now) {
      error_type = "accessdenied"
      error = "Sessão expirada. Reinicie o cadastro."
    }
  
    precondition ($session.email_code == $input.code) {
      error_type = "accessdenied"
      error = "Código inválido."
    }
  
    db.edit signup_session {
      field_name = "id"
      field_value = $session.id
      enforce_hidden_fields = false
      data = {email_verified: true}
    }
  }

  response = {success: true}
  guid = "nn6N5_AKwzNGuhjWbnNMF9oShnQ"
}