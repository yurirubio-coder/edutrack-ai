query "auth/login" verb=POST {
  api_group = "Gestão"

  input {
    email email filters=trim|lower
    text password {
      sensitive = true
    }
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email
      output = ["id", "created_at", "name", "email", "password", "papel_id"]
    } as $user
  
    precondition ($user != null) {
      error_type = "accessdenied"
      error = "Credenciais inválidas."
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $user.password
    } as $pass_result
  
    precondition ($pass_result) {
      error_type = "accessdenied"
      error = "Credenciais inválidas."
    }
  
    db.get papel {
      field_name = "id"
      field_value = $user.papel_id
    } as $papel
  
    precondition ($papel != null) {
      error_type = "accessdenied"
      error = "Perfil de acesso inválido."
    }
  
    precondition ($papel.name == "Admin" || $papel.name == "Atendente" || $papel.name == "Cozinheiro") {
      error_type = "accessdenied"
      error = "Usuário sem permissão para acessar o painel de gestão."
    }
  
    security.create_auth_token {
      table = "user"
      extras = {papel_id: $user.papel_id, papel: $papel.name}
      expiration = 86400
      id = $user.id
    } as $authToken
  
    var.update $user {
      value = $user|set:"papel":$papel
    }
  }

  response = {authToken: $authToken, user: $user}
  guid = "RzKvaKhlBkBVz5NeR2d1IRyWHUY"
}