query "auth/signup/phone" verb=POST {
  api_group = "Authentication"

  input {
    text signup_token
    text celular
  }

  stack {
    db.query signup_session {
      where = $db.signup_session.token == $input.signup_token
      return = {type: "single"}
    } as $session
  
    precondition ($session != null) {
      error = "Sessão inválida."
    }
  
    precondition ($session.email_verified) {
      error = "E-mail não verificado."
    }
  
    var $now {
      value = "now"|add_secs_to_timestamp:0
    }
  
    precondition ($session.expiration > $now) {
      error_type = "accessdenied"
      error = "Sessão expirada. Reinicie o cadastro."
    }
  
    var $digits {
      value = $input.celular
        |replace:"(":""
        |replace:")":""
        |replace:"-":""
        |replace:" ":""
        |replace:"+":""
    }
  
    conditional {
      if ($digits|starts_with:"55") {
        var.update $digits {
          value = $digits|substr:2
        }
      }
    }
  
    var $digits_len {
      value = $digits|strlen|to_int
    }
  
    precondition ($digits_len == 11) {
      error_type = "accessdenied"
      error = "Celular no formato inválido."
    }
  
    var $ddd {
      value = $digits|substr:0:2
    }
  
    var $nono_digito {
      value = $digits|substr:2:1
    }
  
    precondition (($ddd|to_int) >= 11 && ($ddd|to_int) <= 99) {
      error_type = "accessdenied"
      error = "DDD inválido."
    }
  
    precondition ($nono_digito == "9") {
      error_type = "accessdenied"
      error = "Celular no formato inválido."
    }
  
    var $normalized_phone {
      value = "55" ~ $digits
    }
  
    db.query cliente {
      where = $db.cliente.celular == $normalized_phone
      return = {type: "single"}
    } as $existing_phone
  
    precondition ($existing_phone == null) {
      error_type = "accessdenied"
      error = "Celular já cadastrado."
    }
  
    var $uuid_sms {
      value = ""|uuid
    }
  
    var $raw_code_sms {
      value = $uuid_sms|create_uid|modulus:1000000
    }
  
    var $code_sms {
      value = "%06d"|sprintf:$raw_code_sms
    }
  
    db.edit signup_session {
      field_name = "id"
      field_value = $session.id
      enforce_hidden_fields = false
      data = {celular: $normalized_phone, phone_code: $code_sms}
    }
  
    api.request {
      url = "https://api.twilio.com/2010-04-01/Accounts/" ~ $env.TWILIO_ACCOUNT_SID ~ "/Messages.json"
      method = "POST"
      params = {
        To  : "+" ~ $normalized_phone
        From: $env.TWILIO_PHONE_NUMBER
        Body: "Sabor Local: seu código de verificação é %s — expira em 15 minutos."|sprintf:$code_sms
      }
    
      headers = [
        "Authorization: Basic " ~ (($env.TWILIO_ACCOUNT_SID ~ ":" ~ $env.TWILIO_AUTH_TOKEN)|base64_encode)
        "Content-Type: application/x-www-form-urlencoded"
      ]
    } as $send_sms
  
    precondition ($send_sms != null) {
      error_type = "accessdenied"
      error = "Falha ao enviar SMS."
    }
  }

  response = {success: true}
  guid = "q6jsCrQqWIgtRhCIllaaBAh5ZwI"
}