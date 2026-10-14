query buscar_endereco_padrao verb=GET {
  api_group = "Members & Accounts"
  auth = "user"

  input {
  }

  stack {
    // Primeiro buscamos o registro do cliente associado ao usuário logado
    db.get cliente {
      field_name = "user_id"
      field_value = $auth.id
    } as $cliente
  
    // Agora buscamos o endereço marcado como padrão para este cliente
    db.query endereco {
      where = $db.endereco.cliente_id == $cliente.id && $db.endereco.padrao == true
      return = {type: "single"}
    } as $endereco_padrao
  }

  response = $endereco_padrao
  guid = "f0bVTqg1NROU0Dcajtu-eBABSuc"
}