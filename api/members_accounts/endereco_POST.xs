// Add endereco record
query endereco verb=POST {
  api_group = "Members & Accounts"

  input {
    int cliente_id
    text logradouro?
    text numero?
    text complemento?
    text bairro?
    text referencia?
    bool padrao?
    int cep_id
  }

  stack {
    db.add endereco {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        cliente_id : $input.cliente_id
        logradouro : $input.logradouro
        numero     : $input.numero
        complemento: $input.complemento
        bairro     : $input.bairro
        referencia : $input.referencia
        padrao     : $input.padrao
        cep_id     : $input.cep_id
      }
    } as $endereco
  }

  response = $endereco
  guid = "-iiDIEM1Q4iScMUt_3QkFvRmN5Q"
}