query "promocoes/remover-produto" verb=PATCH {
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
      data = {em_promocao: false, preco_promocional: null}
    } as $produto
  }

  response = {success: true, produto: $produto}
  guid = "OPH8Yul2PLZTSjavQTlNVrcBfC0"
}