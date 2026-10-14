query buscaCLIENTE verb=GET {
  api_group = "Endereços"

  input {
    text authToken filters=min:1|max:1000|trim
  }

  stack {
    api.request {
      url = $env.URL_BASE_AUTH ~ "/auth/me"
      method = "GET"
      headers = []
        |push:"Authorization: Bearer " ~ $input.authToken
        |push:"Content-Type: application/json"
    } as $api1
  
    precondition ($api1.response.status == 200) {
      error_type = "accessdenied"
      error = "Token inválido."
    }
  
    db.get cliente {
      field_name = "user_id"
      field_value = $api1.response.result.id
    } as $CLIENTE1
  
    precondition ($CLIENTE1 != null) {
      error_type = "notfound"
      error = "Cliente não encontrado."
    }
  }

  response = $CLIENTE1
  guid = "8zEc2U55dImiK7XSjBRCOR7K2-0"
}