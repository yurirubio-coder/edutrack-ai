query "auth/request_password_reset" verb=POST {
  api_group = "Authentication"

  input {
    email email filters=trim|lower
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user
  
    precondition ($user != null) {
      error_type = "notfound"
      error = "usuário não encontrado."
    }
  
    var $one_hour_ago {
      value = "now"|transform_timestamp:"-1 hour"
    }
  
    db.query verification_code {
      where = $db.verification_code.user_id == $user.id && $db.verification_code.type == "password_reset" && $db.verification_code.created_at >= $one_hour_ago
      return = {type: "list"}
    } as $recent_codes
  
    // se quiser limitar reenvios, descomente isso
    // precondition (($recent_codes|count) < 3) {
    //   error_type = "accessdenied"
    //   error = "limite de reenvio atingido. tente novamente mais tarde."
    // }
  
    db.query verification_code {
      where = $db.verification_code.user_id == $user.id && $db.verification_code.type == "password_reset" && $db.verification_code.used == false
      return = {type: "list"}
    } as $old_codes
  
    conditional {
      if (($old_codes|count) > 0) {
        foreach ($old_codes) {
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
  
    var $uuid {
      value = ""|uuid
    }
  
    var $raw_code {
      value = $uuid|create_uid|modulus:1000000
    }
  
    var $code {
      value = "%06d"|sprintf:$raw_code
    }
  
    var $expiration {
      value = "now"|add_secs_to_timestamp:900
    }
  
    db.add verification_code {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        user_id   : $user.id
        code      : $code
        expiration: $expiration
        used      : false
        attempts  : 0
        type      : "password_reset"
      }
    } as $vcode
  
    api.request {
      url = "https://api.resend.com/emails"
      method = "POST"
      params = {
        from   : "sabor local <mail@mail.mintr.online>"
        to     : [$user.email]
        subject: "redefinição de senha - sabor local"
        text   : "seu código para redefinir senha é: %s — expira em 15 minutos."|sprintf:$code
      }
    
      headers = []
        |push:"authorization: bearer " ~ $env.RESEND_API_KEY
        |push:"content-type: application/json"
    } as $send_email
  
    precondition ($send_email != null) {
      error_type = "accessdenied"
      error = "falha ao enviar e-mail de redefinição."
    }
  }

  response = {
    success: true
    message: "código enviado para o e-mail informado."
  }

  tags = ["auth"]
  guid = "ErEwyYYm5pveqdVEzHH9wDSozoI"
}