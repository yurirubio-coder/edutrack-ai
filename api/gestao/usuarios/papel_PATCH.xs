// API para alterar o papel dos usuários
query "usuarios/papel" verb=PATCH {
  api_group = "Gestão"
  auth = "user"

  input {
    int user_id
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
  
    precondition ($auth_papel.name == "ADM") {
      error_type = "accessdenied"
      error = "Apenas ADM pode alterar níveis de acesso."
    }
  
    db.get user {
      field_name = "id"
      field_value = $input.user_id
    } as $target_user
  
    precondition ($target_user != null) {
      error_type = "notfound"
      error = "Usuário não encontrado."
    }
  
    db.get papel {
      field_name = "id"
      field_value = $input.papel_id
    } as $novo_papel
  
    precondition ($novo_papel != null) {
      error_type = "notfound"
      error = "Papel inválido."
    }
  
    db.edit user {
      field_name = "id"
      field_value = $input.user_id
      enforce_hidden_fields = false
      data = {papel_id: $input.papel_id}
    } as $updated_user
  }

  response = {success: true, user: $updated_user}
  guid = "IV3iibhp5I54k9W82zwXBgDEcLY"
}