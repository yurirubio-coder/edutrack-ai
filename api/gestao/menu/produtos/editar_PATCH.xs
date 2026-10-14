query "menu/produtos/editar" verb=PATCH {
  api_group = "Gestão"
  auth = "user"

  input {
    int produto_id
    text codigo
    text nome
    text descricao
    int qtd_disp
    decimal preco
    bool precisa_produzir
    text url_imagem?
    bool ativo
    int tipo_produto_id
    bool vegetariano
    bool sem_gluten
    bool em_promocao
    decimal preco_promocional?
    int ordem_catalogo
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
      data = {
        codigo           : $input.codigo
        nome             : $input.nome
        descricao        : $input.descricao
        qtd_disp         : $input.qtd_disp
        preco            : $input.preco
        precisa_produzir : $input.precisa_produzir
        url_imagem       : $input.url_imagem
        ativo            : $input.ativo
        tipo_produto_id  : $input.tipo_produto_id
        vegetariano      : $input.vegetariano
        sem_gluten       : $input.sem_gluten
        em_promocao      : $input.em_promocao
        preco_promocional: $input.preco_promocional
        ordem_catalogo   : $input.ordem_catalogo
      }
    } as $produto
  }

  response = {success: true, produto: $produto}
  guid = "x75K9ur6FiZLX2c8x7iD3u1PnT8"
}