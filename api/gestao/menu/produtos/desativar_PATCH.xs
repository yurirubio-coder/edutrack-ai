query "menu/produtos/desativar" verb=PATCH {
  api_group = "Gestão"
  auth = "user"

  input {
    int produto_id
  }

  stack {
    db.get produto {
      field_name = "id"
      field_value = $input.produto_id
    } as $produto_atual
  
    precondition ($produto_atual != null) {
      error_type = "notfound"
      error = "Produto não encontrado."
    }
  
    db.edit produto {
      field_name = "id"
      field_value = $input.produto_id
      enforce_hidden_fields = false
      data = {ativo: false}
    } as $produto
  }

  response = {success: true, produto: $produto}
  guid = "vzcHKEk1ITuEnbsvYvOGIU6LvcU"
}