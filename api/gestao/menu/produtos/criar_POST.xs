query "menu/produtos/criar" verb=POST {
  api_group = "Gestão"
  auth = "user"

  input {
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
    db.get tipo_produto {
      field_name = "id"
      field_value = $input.tipo_produto_id
    } as $tipo_produto
  
    precondition ($tipo_produto != null) {
      error_type = "notfound"
      error = "Tipo de produto inválido."
    }
  
    db.query produto {
      where = $db.produto.codigo == $input.codigo
      return = {type: "single"}
    } as $existing_produto
  
    precondition ($existing_produto == null) {
      error_type = "accessdenied"
      error = "Já existe um produto com este código."
    }
  
    db.add produto {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
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
        qtd_vendida      : 0
      }
    } as $produto
  }

  response = {success: true, produto: $produto}
  guid = "of5yIFnyv3cPLXJ288RIYwy7Dkg"
}