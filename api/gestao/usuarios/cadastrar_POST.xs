// API para criar um usuário para acessar o sistema de gestão
query "usuarios/cadastrar" verb=POST {
  api_group = "Gestão"
  auth = "user"

  input {
    text name
    email email filters=trim|lower
    text password {
      sensitive = true
    }
  
    int papel_id
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $auth_user
  
    db.get papel {
      field_name = "id"
      field_value = $auth_user.papel_id
    } as $auth_papel
  
    precondition ($auth_papel.name == "Admin" || $auth_papel.name == "Atendente") {
      error_type = "accessdenied"
      error = "Você não tem permissão para cadastrar usuários."
    }
  
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $existing_user
  
    precondition ($existing_user == null) {
      error_type = "accessdenied"
      error = "Este e-mail já está cadastrado."
    }
  
    db.get papel {
      field_name = "id"
      field_value = $input.papel_id
    } as $novo_papel
  
    precondition ($novo_papel != null) {
      error_type = "notfound"
      error = "Papel inválido."
    }
  
    precondition ($novo_papel.name == "Admin" || $novo_papel.name == "Atendente" || $novo_papel.name == "Cozinheiro") {
      error_type = "accessdenied"
      error = "Este papel não pode acessar o painel de gestão."
    }
  
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at         : "now"
        name               : $input.name
        email              : $input.email
        password           : $input.password
        papel_id           : $input.papel_id
        password_reset     : {token: null, expiration: null, used: true}
        login_attempts     : 0
        login_blocked_until: null
      }
    } as $user
  }

  response = {success: true, user: $user}
  guid = "_JRJnO_LJfmddeTgvs56L5A-b3o"
}