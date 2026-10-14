// ATTENTION: This API route is for password recovery
query "auth/verify_reset_code" verb=POST {
  api_group = "Authentication"

  input {
    email email filters=trim|lower
    text code
  }

  stack {
    // 1) Buscar user
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user
  
    precondition ($user != null) {
      error_type = "notfound"
      error = "Usuário não encontrado."
    }
  
    // 2) Buscar code ativo tipo password_reset (mais recente)
    db.query verification_code {
      where = $db.verification_code.user_id == $user.id && $db.verification_code.type == "password_reset" && $db.verification_code.used == false
      sort = {created_at: "desc"}
      return = {type: "single"}
    } as $vcode
  
    precondition ($vcode != null) {
      error_type = "accessdenied"
      error = "Nenhum código válido encontrado. Solicite um novo código."
    }
  
    // 3) Verificar tentativas
    precondition ($vcode.attempts < 5) {
      error_type = "accessdenied"
      error = "Muitas tentativas inválidas. Solicite novo código."
    }
  
    // Obter timestamp atual
    var $now {
      value = "now"|add_secs_to_timestamp:0
    }
  
    // Verificar se o código não expirou
    precondition ($vcode.expiration > $now) {
      error_type = "accessdenied"
      error = "Verification code has expired. Please request a new one."
    }
  
    // 4) Validar código
    conditional {
      if ($input.code != $vcode.code) {
        // incrementa attempts
        db.edit verification_code {
          field_name = "id"
          field_value = $vcode.id
          enforce_hidden_fields = false
          data = {attempts: $vcode.attempts + 1}
        } as $updated_vcode_attempts
      
        precondition (false) {
          error_type = "accessdenied"
          error = "Código inválido."
        }
      }
    }
  
    // 5) Marcar verification_code como usado
    db.edit verification_code {
      field_name = "id"
      field_value = $vcode.id
      enforce_hidden_fields = false
      data = {used: true}
    } as $used_vcode
  
    // 6) Gerar reset_token (UUID) e salvar em user.password_reset
    var $uuid {
      value = ""|uuid
    }
  
    var $reset_exp {
      value = "now"|add_secs_to_timestamp:900
    }
  
    db.edit user {
      field_name = "id"
      field_value = $user.id
      enforce_hidden_fields = false
      data = {
        password_reset: {token: $uuid, expiration: $reset_exp, used: false}
      }
    } as $updated_user
  
    // 7) Retorna reset_token (o app usará para /auth/reset_password)
  }

  response = {
    success    : true
    reset_token: $uuid
    message    : "Código validado. Use o token para redefinir a senha."
  }

  tags = ["auth"]
  guid = "27NCTg4jPv7EEifnpWnlt9-6ocM"
}