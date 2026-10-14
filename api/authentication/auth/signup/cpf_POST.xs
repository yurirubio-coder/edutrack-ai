query "auth/signup/cpf" verb=POST {
  api_group = "Authentication"

  input {
    text signup_token
    text cpf
  }

  stack {
    db.query signup_session {
      where = $db.signup_session.token == $input.signup_token
      eval = {password: $db.signup_session.password}
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
  
    var $cpf_digits {
      value = $input.cpf
        |to_text
        |replace:".":""
        |replace:"-":""
        |replace:" ":""
    }
  
    var $cpf_is_numeric {
      value = "/^[0-9]+$/"|regex_matches:$cpf_digits
    }
  
    precondition ($cpf_is_numeric) {
      error_type = "accessdenied"
      error = "CPF deve conter apenas números."
    }
  
    var $cpf_len {
      value = $cpf_digits|strlen
    }
  
    precondition ($cpf_len == 11) {
      error_type = "accessdenied"
      error = "CPF no formato inválido."
    }
  
    var $bad_cpfs {
      value = [
        "00000000000"
        "11111111111"
        "22222222222"
        "33333333333"
        "44444444444"
        "55555555555"
        "66666666666"
        "77777777777"
        "88888888888"
        "99999999999"
      ]
    }
  
    var $is_bad_cpf {
      value = $bad_cpfs|contains:$cpf_digits
    }
  
    precondition ($is_bad_cpf == false) {
      error_type = "accessdenied"
      error = "CPF inválido."
    }
  
    var $cpf_d1_sum {
      value = (($cpf_digits|substr:0:1|to_int) * 10 + ($cpf_digits|substr:1:1|to_int) * 9 + ($cpf_digits|substr:2:1|to_int) * 8 + ($cpf_digits|substr:3:1|to_int) * 7 + ($cpf_digits|substr:4:1|to_int) * 6 + ($cpf_digits|substr:5:1|to_int) * 5 + ($cpf_digits|substr:6:1|to_int) * 4 + ($cpf_digits|substr:7:1|to_int) * 3 + ($cpf_digits|substr:8:1|to_int) * 2)
    }
  
    var $cpf_d1_rem {
      value = $cpf_d1_sum|modulus:11
    }
  
    var $cpf_d1 {
      value = 0
    }
  
    conditional {
      if ($cpf_d1_rem >= 2) {
        var.update $cpf_d1 {
          value = 11 - $cpf_d1_rem
        }
      }
    }
  
    var $provided_d1 {
      value = $cpf_digits|substr:9:1|to_int
    }
  
    precondition ($cpf_d1 == $provided_d1) {
      error_type = "accessdenied"
      error = "CPF inválido."
    }
  
    var $cpf_d2_sum {
      value = (($cpf_digits|substr:0:1|to_int) * 11 + ($cpf_digits|substr:1:1|to_int) * 10 + ($cpf_digits|substr:2:1|to_int) * 9 + ($cpf_digits|substr:3:1|to_int) * 8 + ($cpf_digits|substr:4:1|to_int) * 7 + ($cpf_digits|substr:5:1|to_int) * 6 + ($cpf_digits|substr:6:1|to_int) * 5 + ($cpf_digits|substr:7:1|to_int) * 4 + ($cpf_digits|substr:8:1|to_int) * 3 + ($cpf_digits|substr:9:1|to_int) * 2)
    }
  
    var $cpf_d2_rem {
      value = $cpf_d2_sum|modulus:11
    }
  
    var $cpf_d2 {
      value = 0
    }
  
    conditional {
      if ($cpf_d2_rem >= 2) {
        var.update $cpf_d2 {
          value = 11 - $cpf_d2_rem
        }
      }
    }
  
    var $provided_d2 {
      value = $cpf_digits|substr:10:1|to_int
    }
  
    precondition ($cpf_d2 == $provided_d2) {
      error_type = "accessdenied"
      error = "CPF inválido."
    }
  
    db.query cliente {
      where = $db.cliente.cpf == $cpf_digits
      return = {type: "single"}
    } as $existing_cpf
  
    precondition ($existing_cpf == null) {
      error_type = "accessdenied"
      error = "CPF já cadastrado."
    }
  
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at         : "now"
        name               : $session.name
        email              : $session.email
        password           : $session.password
        papel_id           : 6
        status_cliente_id  : 2
        password_reset     : {token: null, expiration: null, used: true}
        login_attempts     : 0
        login_blocked_until: null
      }
    } as $user
  
    db.add cliente {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
        name             : $user.name
        celular          : $session.celular
        cpf              : $cpf_digits
        status_cliente_id: 2
        user_id          : $user.id
      }
    } as $cliente
  
    conditional {
      if ($cliente == null) {
        db.del user {
          field_name = "id"
          field_value = $user.id
        }
      
        precondition (false) {
          error = "Erro criando o cliente. Registro cancelado."
        }
      }
    }
  
    db.del signup_session {
      field_name = "id"
      field_value = $session.id
    }
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 86400
      id = $user.id
    } as $authToken
  }

  response = {authToken: $authToken, user_id: $user.id}
  guid = "PkGyOYYwu3-9MC5mYYZ2iQ0Cb0k"
}