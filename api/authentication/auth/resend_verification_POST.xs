query "auth/resend_verification" verb=POST {
  api_group = "Authentication"

  input {
    text signup_token
  }

  stack {
    db.query signup_session {
      where = $db.signup_session.token == $input.signup_token
      return = {type: "single"}
    } as $session
  
    precondition ($session != null) {
      error_type = "accessdenied"
      error = "Sessão inválida."
    }
  
    precondition ($session.email_verified == false) {
      error_type = "accessdenied"
      error = "E-mail já verificado."
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
  
    db.edit signup_session {
      field_name = "id"
      field_value = $session.id
      enforce_hidden_fields = false
      data = {email_code: $code, expiration: $expiration}
    } as $updated_session
  
    api.request {
      url = "https://api.resend.com/emails"
      method = "POST"
      params = {
        from   : "Sabor Local <mail@mail.mintr.online>"
        to     : [$session.email]
        subject: "Novo código de verificação - Sabor Local"
        text   : "Seu novo código de verificação é: %s — expira em 15 minutos."|sprintf:$code
      }
    
      headers = []
        |push:"Authorization: Bearer " ~ $env.RESEND_API_KEY
        |push:"Content-Type: application/json"
    } as $send_email
  
    precondition ($send_email != null) {
      error_type = "accessdenied"
      error = "Falha ao enviar e-mail."
    }
  }

  response = {
    success: true
    message: "Código reenviado para o e-mail."
  }

  guid = "RPgy-7qqgc-xzjeYqF6gDOviqVc"
}