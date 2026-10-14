query "produtos/tipo" verb=GET {
  api_group = "Catalog"

  input {
    int tipo_produto_id
  }

  stack {
    db.get tipo_produto {
      field_name = "id"
      field_value = $input.tipo_produto_id
    } as $tipo_produto
  
    precondition ($tipo_produto != null) {
      error_type = "notfound"
      error = "Tipo de produto não encontrado."
    }
  
    db.query produto {
      where = $db.produto.ativo == true && $db.produto.tipo_produto_id == $input.tipo_produto_id
      sort = {ordem_catalogo: "asc", id: "asc"}
      return = {type: "list"}
    } as $produtos
  
    conditional {
      if (($produtos|count) > 0) {
        foreach ($produtos) {
          each as $produto_item {
            db.query produto_personalizacao {
              where = $db.produto_personalizacao.produto_id == $produto_item.id
              sort = {ordem_exibicao: "asc"}
              return = {type: "list"}
            } as $personalizacoes
          
            conditional {
              if (($personalizacoes|count) > 0) {
                foreach ($personalizacoes) {
                  each as $personalizacao_item {
                    db.query produto_personalizacao_opcao {
                      where = $db.produto_personalizacao_opcao.produto_personalizacao_id == $personalizacao_item.id && $db.produto_personalizacao_opcao.ativo == true
                      sort = {ordem_exibicao: "asc"}
                      return = {type: "list"}
                    } as $opcoes
                  
                    var.update $personalizacao_item {
                      value = $personalizacao_item|set:"opcoes":$opcoes
                    }
                  }
                }
              }
            }
          
            var.update $produto_item {
              value = $produto_item
                |set:"tipo_produto":$tipo_produto
                |set:"personalizacoes":$personalizacoes
            }
          }
        }
      }
    }
  }

  response = {tipo_produto: $tipo_produto, produtos: $produtos}
  guid = "5D2RM24Rv1v0AVeWpN46LxegtsI"
}