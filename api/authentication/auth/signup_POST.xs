// Endpoint base para cadastro.
query "auth/signup" verb=POST {
  api_group = "Authentication"

  input {
    text name
    email email filters=trim|lower
    text password {
      sensitive = true
    }
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $existing_user
  
    precondition ($existing_user == null) {
      error_type = "accessdenied"
      error = "Essa conta já está em uso."
    }
  
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at    : "now"
        name          : $input.name
        email         : $input.email
        password      : $input.password
        password_reset: {token: null, expiration: null, used: true}
      }
    } as $user
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 86400
      id = $user.id
    } as $authToken
  }

  response = {authToken: $authToken, user_id: $user.id}
  guid = "rUG4j5xdPgFjFGPIKXqnl6q3lKo"
}