// ATENÇÃO: Essa API não é utilizada no verdadeiro fluxo de cadastro.
// Essa API só está aqui para fins acadêmicos.
query cadastraCliente verb=POST {
  api_group = "College"

  input {
    text nome
    email email filters=trim|lower
    text senha {
      sensitive = true
    }
  
    text celular
    text cpf
    text status
  }

  stack {
    api.request {
      url = $env.API_BASE_URL ~ "/auth/signup"
      method = "POST"
      params = {
        name    : $input.nome
        email   : $input.email
        password: $input.senha
      }
    
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    precondition ($api1.response.status == 200) {
      error = $api1.response.result.message != null ? $api1.response.result.message : "Falha ao criar usuário."
    }
  
    precondition ($api1.response.result.authToken != null) {
      error = "Falha ao criar usuário."
    }
  
    api.request {
      url = $env.API_BASE_URL ~ "/auth/me"
      method = "GET"
      headers = []
        |push:"Authorization: Bearer " ~ $api1.response.result.authToken
        |push:"Content-Type: application/json"
    } as $api2
  
    precondition ($api2.response.result.id != null) {
      error = "Falha ao recuperar user_id."
    }
  
    db.query status_cliente {
      where = $db.status_cliente.nome == $input.status
      return = {type: "single"}
    } as $status_cliente
  
    precondition ($status_cliente != null) {
      error_type = "notfound"
      error = "Status do cliente inválido."
    }
  
    db.query cliente {
      where = $db.cliente.cpf == $input.cpf
      return = {type: "single"}
    } as $existing_cpf
  
    precondition ($existing_cpf == null) {
      error_type = "accessdenied"
      error = "CPF já cadastrado."
    }
  
    db.query cliente {
      where = $db.cliente.celular == $input.celular
      return = {type: "single"}
    } as $existing_phone
  
    precondition ($existing_phone == null) {
      error_type = "accessdenied"
      error = "Celular já cadastrado."
    }
  
    db.add cliente {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
        name             : $input.nome
        celular          : $input.celular
        cpf              : $input.cpf
        status_cliente_id: $status_cliente.id
        user_id          : $api2.response.result.id
      }
    } as $cliente
  }

  response = {
    user     : $api2.response.result
    cliente  : $cliente
    authToken: $api1.response.result.authToken
  }

  guid = "4RqHly3AdA_4PUAXmcCFJX-ywKo"
}