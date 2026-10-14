query produtos verb=GET {
  api_group = "Catalog"

  input {
  }

  stack {
    db.query produto {
      where = $db.produto.ativo == true
      sort = {ordem_catalogo: "asc", id: "asc"}
      return = {type: "list"}
    } as $produtos
  
    conditional {
      if (($produtos|count) > 0) {
        foreach ($produtos) {
          each as $produto_item {
            db.get tipo_produto {
              field_name = "id"
              field_value = $produto_item.tipo_produto_id
            } as $tipo_produto_item
          
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
                |set:"tipo_produto":$tipo_produto_item
                |set:"personalizacoes":$personalizacoes
            }
          }
        }
      }
    }
  }

  response = $produtos
  guid = "W1ZBS6L8quNkQ6lkumVZuXbt7gI"
}