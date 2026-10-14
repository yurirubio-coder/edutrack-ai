query criarclienteasaas verb=POST {
  api_group = "CustomAPIs"

  input {
    text authtoken? filters=trim
  }

  stack {
    api.request {
      url = "https://x8ki-letl-twmt.n7.xano.io/api:SM3XXsQ6/buscaCLIENTE"
      method = "GET"
      params = {authToken: $input.authtoken}
    } as $api1
  
    conditional {
      if (`$var.api1.response.status` == 200) {
        db.get user {
          field_name = "id"
          field_value = `$var.api1.response.result.user_id`
        } as $user1
      
        db.get tokens {
          field_name = "plataforma"
          field_value = "Asaas"
        } as $tokens1
      
        api.request {
          url = "https://sandbox.asaas.com/api/v3/customers"
          method = "POST"
          params = {name: $user1.name, cpfCnpj: $api1.response.result.cpf}
          headers = []
            |push:"User-Agent: XanoApp/1.0 (contact: vitor.foliveira@impacta.edu.br)"
            |push:"Accept: application/json"
            |push:$tokens1.token
            |push:"Content-Type: application/json"
        } as $api2
      
        var $codigoclienteassas {
          value = `$var.api2.response.result.id`
        }
      
        db.get status_ttokenizacao {
          field_name = "status"
          field_value = `"Criada"`
        } as $STATUS_TTOKENIZACAO1
      
        db.add ttokenizacao {
          enforce_hidden_fields = false
          data = {
            created_at            : "now"
            cliente_id            : `$var.api1.response.result.id`
            det_cartao_encript    : ""
            status_ttokenizacao_id: `$var.STATUS_TTOKENIZACAO1.id`
          }
        } as $TTOKENIZACAO1
      
        db.add cartaotoknzd {
          enforce_hidden_fields = false
          data = {
            created_at        : "now"
            cliente_id        : `$var.api1.response.result.id`
            token             : ""
            codigoclienteassas: `$var.codigoclienteassas`
          }
        } as $CARTAOTOKNZD1
      
        var $status {
          value = {status: true, mensagem: "Cliente cadastrado no Assas."}
        }
      }
    
      else {
        var $status {
          value = {
            status  : false
            mensagem: "Cliente não pôde ser cadastrado no Assas."
          }
        }
      }
    }
  }

  response = {status: $status}
  guid = "UDoszLZF-BsBvSWKu4tjflqBxFM"
}