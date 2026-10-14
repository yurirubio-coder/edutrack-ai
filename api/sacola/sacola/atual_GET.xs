query "sacola/atual" verb=GET {
  api_group = "sacola"
  auth = "user"

  input {
  }

  stack {
    db.get cliente {
      field_name = "user_id"
      field_value = $auth.id
    } as $cliente
  
    precondition ($cliente != null) {
      error_type = "accessdenied"
      error = "Cliente não encontrado."
    }
  
    db.query sacola {
      where = $db.sacola.cliente_id == $cliente.id && $db.sacola.status_sacola_id == 1
      return = {type: "single"}
    } as $sacola
  
    conditional {
      if ($sacola == null) {
        db.add sacola {
          enforce_hidden_fields = false
          data = {
            created_at      : "now"
            cliente_id      : $cliente.id
            subtotal        : 0
            desconto        : 0
            total           : 0
            status_sacola_id: 1
          }
        } as $sacola
      }
    }
  
    db.query sacola_item {
      where = $db.sacola_item.sacola_id == $sacola.id
      sort = {created_at: "asc", id: "asc"}
      return = {type: "list"}
    } as $itens
  
    conditional {
      if (($itens|count) > 0) {
        foreach ($itens) {
          each as $item {
            db.get produto {
              field_name = "id"
              field_value = $item.produto_id
            } as $produto
          
            db.query sacola_item_personalizacao {
              where = $db.sacola_item_personalizacao.sacola_item_id == $item.id
              return = {type: "list"}
            } as $personalizacoes_item
          
            conditional {
              if (($personalizacoes_item|count) > 0) {
                foreach ($personalizacoes_item) {
                  each as $personalizacao_item {
                    db.get produto_personalizacao {
                      field_name = "id"
                      field_value = $personalizacao_item.produto_personalizacao_id
                    } as $personalizacao
                  
                    db.get produto_personalizacao_opcao {
                      field_name = "id"
                      field_value = $personalizacao_item.produto_personalizacao_opcao_id
                    } as $opcao
                  
                    var.update $personalizacao_item {
                      value = $personalizacao_item
                        |set:"personalizacao":$personalizacao
                        |set:"opcao":$opcao
                    }
                  }
                }
              }
            }
          
            var.update $item {
              value = $item
                |set:"produto":$produto
                |set:"personalizacoes":$personalizacoes_item
                |set:"subtotal_formatado":"R$ " ~ ($item.subtotal|to_text)
            }
          }
        }
      }
    }
  
    var.update $sacola {
      value = $sacola
        |set:"items":$itens
        |set:"resumo":```
          {
            subtotal: $sacola.subtotal,
            desconto: $sacola.desconto,
            total: $sacola.total,
            subtotal_formatado: "R$ " ~ ($sacola.subtotal|to_text),
            desconto_formatado: "R$ " ~ ($sacola.desconto|to_text),
            total_formatado: "R$ " ~ ($sacola.total|to_text)
          }
          ```
    }
  }

  response = $sacola
  guid = "2FGaiq-2Vu86ePq8uBRwBSM22u4"
}