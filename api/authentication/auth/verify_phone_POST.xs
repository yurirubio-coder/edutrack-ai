query "auth/verify_phone" verb=POST {
  api_group = "Authentication"
  auth = "user"

  input {
    text code
  }

  stack {
    // Buscar código ativo do tipo phone_verification
    db.query verification_code {
      where = $db.verification_code.user_id == $auth.id && $db.verification_code.type == "phone_verification" && $db.verification_code.used == false
      sort = {created_at: "desc"}
      return = {type: "single"}
    } as $vcode
  
    precondition ($vcode != null) {
      error_type = "accessdenied"
      error = "No active verification code found."
    }
  
    precondition ($vcode.attempts < 5) {
      error_type = "accessdenied"
      error = "Too many failed attempts. Please request a new code."
    }
  
    var $now {
      value = "now"|to_timestamp
    }
  
    precondition ($vcode.expiration > $now) {
      error_type = "accessdenied"
      error = "Verification code has expired. Please request a new one."
    }
  
    // Validar código
    conditional {
      if ($input.code != $vcode.code) {
        db.edit verification_code {
          field_name = "id"
          field_value = $vcode.id
          enforce_hidden_fields = false
          data = {attempts: $vcode.attempts + 1}
        } as $updated_vcode
      
        precondition (false) {
          error_type = "accessdenied"
          error = "Invalid verification code."
        }
      }
    }
  
    // Marcar código como usado
    db.edit verification_code {
      field_name = "id"
      field_value = $vcode.id
      enforce_hidden_fields = false
      data = {used: true}
    } as $used_vcode
  
    // Buscar e verificar cliente
    db.get cliente {
      field_name = "user_id"
      field_value = $auth.id
    } as $cliente
  
    precondition ($cliente != null) {
      error_type = "notfound"
      error = "Cliente record not found for this user."
    }
  
    // Atualizar status para Verificado (id = 2)
    db.edit cliente {
      field_name = "id"
      field_value = $cliente.id
      enforce_hidden_fields = false
      data = {status_cliente_id: 2}
    } as $updated_cliente
  }

  response = {success: true, message: "Phone verified successfully."}
  guid = "IA1GrbEx2HV11kZgzfNCs_vt3To"
}