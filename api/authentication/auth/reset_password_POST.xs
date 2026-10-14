query "auth/reset_password" verb=POST {
  api_group = "Authentication"

  input {
    text reset_token
    text new_password {
      sensitive = true
    }
  }

  stack {
    // 1) Buscar user com esse reset_token
    db.query user {
      where = $db.user.password_reset != null && $db.user.password_reset.token == $input.reset_token && $db.user.password_reset.used == false
      return = {type: "single"}
      output = ["id", "password_reset"]
    } as $user_row
  
    precondition ($user_row != null) {
      error_type = "accessdenied"
      error = "Token inválido ou expirado."
    }
  
    var $now {
      value = "now"|to_timestamp
    }
  
    var $expiration {
      value = $user_row.password_reset.expiration
    }
  
    precondition ($expiration > $now) {
      error_type = "accessdenied"
      error = "Token expirado."
    }
  
    // 2) Atualizar senha e marcar token como usado
    db.edit user {
      field_name = "id"
      field_value = $user_row.id
      enforce_hidden_fields = false
      data = {
        password      : $input.new_password
        password_reset: {token: null, expiration: null, used: true}
      }
    } as $updated_user
  
    // (Opcional) Invalidar todos os verification_code tipo password_reset para este usuário
    db.query verification_code {
      where = $db.verification_code.user_id == $user_row.id && $db.verification_code.type == "password_reset" && $db.verification_code.used == false
      return = {type: "list"}
    } as $old_codes_to_invalidate
  
    conditional {
      if (($old_codes_to_invalidate|count) > 0) {
        foreach ($old_codes_to_invalidate) {
          each as $c {
            db.edit verification_code {
              field_name = "id"
              field_value = $c.id
              enforce_hidden_fields = false
              data = {used: true}
            } as $updated_code
          }
        }
      }
    }
  }

  response = {
    success: true
    message: "Senha redefinida com sucesso. Faça login com a nova senha."
  }

  tags = ["auth"]
  guid = "qdjniBnPjVSdQkwyh-5X617gRNA"
}