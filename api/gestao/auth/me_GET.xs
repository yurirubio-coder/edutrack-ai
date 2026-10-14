query "auth/me" verb=GET {
  api_group = "Gestão"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["id", "created_at", "name", "email"]
    } as $user
  
    precondition ($user != null) {
      error_type = "notfound"
      error = "Usuário não encontrado."
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
  
    var.update $user {
      value = $user|set:"papel":$papel
    }
  }

  response = $user
  guid = "cOkNazaWNnv0WDtmegzJ3mnHIk0"
}