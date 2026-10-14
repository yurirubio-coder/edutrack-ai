// API para listar usuários no painel
query usuarios verb=GET {
  api_group = "Gestão"
  auth = "user"

  input {
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
      error = "Você não tem permissão para listar usuários."
    }
  
    db.query user {
      sort = {created_at: "desc"}
      return = {type: "list"}
    } as $users
  
    foreach ($users) {
      each as $user_item {
        db.get papel {
          field_name = "id"
          field_value = $user_item.papel_id
        } as $papel_item
      
        var.update $user_item {
          value = $user_item|set:"papel":$papel_item
        }
      }
    }
  }

  response = $users
  guid = "u_I37Kmc4SKOJloit13TxIm_8dA"
}