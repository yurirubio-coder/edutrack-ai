// Add cliente record
query cliente verb=POST {
  api_group = "Members & Accounts"

  input {
    text name?
    text celular?
    text cpf?
    int status_cliente_id?
    int user_id?
  }

  stack {
    db.add cliente {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
        name             : $input.name
        celular          : $input.celular
        cpf              : $input.cpf
        status_cliente_id: $input.status_cliente_id?
        user_id          : $input.user_id?
      }
    } as $cliente
  }

  response = $cliente
  guid = "ZYO3z4ATavUg1snX_q5-orzZlrI"
}