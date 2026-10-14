query "auth/verify_email" verb=POST {
  api_group = "Authentication"
  auth = "user"

  input {
    text code
  }

  stack {
    // Buscar o código de verificação ativo do usuário
    db.query verification_code {
      where = $db.verification_code.user_id == $auth.id && $db.verification_code.type == "email_verification" && $db.verification_code.used == false
      sort = {created_at: "desc"}
      return = {type: "single"}
    } as $vcode
  
    // Verificar se existe um código válido
    precondition ($vcode != null) {
      error_type = "accessdenied"
      error = "No active verification code found."
    }
  
    // Verificar se excedeu o número máximo de tentativas
    precondition ($vcode.attempts < 5) {
      error_type = "accessdenied"
      error = "Too many failed attempts. Please request a new code."
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
  
    // Verificar se o código informado está correto
    conditional {
      if ($input.code != $vcode.code) {
        // Incrementar tentativas
        db.edit verification_code {
          field_name = "id"
          field_value = $vcode.id
          enforce_hidden_fields = false
          data = {attempts: $vcode.attempts + 1}
        } as $updated_vcode_attempts
      
        precondition (false) {
          error_type = "accessdenied"
          error = "Invalid verification code."
        }
      }
    }
  
    // Marcar o código como usado
    db.edit verification_code {
      field_name = "id"
      field_value = $vcode.id
      enforce_hidden_fields = false
      data = {used: true}
    } as $used_vcode
  
    // Buscar o cliente associado ao usuário
    db.get cliente {
      field_name = "user_id"
      field_value = $auth.id
    } as $cliente
  
    // Verificar se o cliente existe
    precondition ($cliente != null) {
      error_type = "notfound"
      error = "Cliente record not found for this user."
    }
  
    // Atualizar status do cliente para Verificado (id = 2)
    db.edit cliente {
      field_name = "id"
      field_value = $cliente.id
      enforce_hidden_fields = false
      data = {status_cliente_id: 2}
    } as $updated_cliente
  }

  response = {success: true, message: "Email verified successfully."}
  guid = "wLsL4kArW42EiFxjoU4Uk6hP3MY"
}