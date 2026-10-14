query "auth/signup/start" verb=POST {
  api_group = "Authentication"

  input {
    email email filters=trim|lower
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $existing_user
  
    precondition ($existing_user == null) {
      error_type = "accessdenied"
      error = "Esse e-mail já está em uso."
    }
  
    var $uuid {
      value = ""|uuid
    }
  
    var $token {
      value = $uuid|create_uid
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
  
    db.add signup_session {
      enforce_hidden_fields = false
      data = {
        created_at    : "now"
        token         : $token
        email         : $input.email
        email_verified: false
        phone_verified: false
        expiration    : $expiration
      }
    } as $session
  
    db.add verification_code {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        user_id   : 0
        code      : $code
        expiration: $expiration
        used      : false
        attempts  : 0
        type      : "email_verification"
      }
    }
  
    // Guarda o code junto ao token para verificar depois
    db.edit signup_session {
      field_name = "id"
      field_value = $session.id
      enforce_hidden_fields = false
      data = {email_code: $code}
    }
  
    api.request {
      url = "https://api.resend.com/emails"
      method = "POST"
      params = {
        from   : "Sabor Local <mail@mail.mintr.online>"
        to     : [$input.email]
        subject: "Código de verificação - Sabor Local"
        text   : "Seu código de verificação é: %s — expira em 15 minutos."|sprintf:$code
      }
    
      headers = []
        |push:"Authorization: Bearer " ~ $env.RESEND_API_KEY
        |push:"Content-Type: application/json"
    }
  }

  response = {signup_token: $token}
  guid = "wuzyebAVhEsHNfyWGWvitaNLpXQ"
}