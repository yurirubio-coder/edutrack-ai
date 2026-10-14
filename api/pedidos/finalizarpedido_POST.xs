query finalizarpedido verb=POST {
  api_group = "Pedidos"
  auth = "user"

  input {
  }

  stack {
    // Identify the client
    db.get cliente {
      field_name = "user_id"
      field_value = $auth.id
    } as $cliente
  
    precondition ($cliente != null) {
      error_type = "accessdenied"
      error = "Cliente não encontrado."
    }
  
    // Locate the active sacola (status 1 = active)
    db.query sacola {
      where = ($db.sacola.cliente_id == $cliente.id) && ($db.sacola.status_sacola_id == 1)
      return = {type: "single"}
    } as $sacola
  
    precondition ($sacola != null) {
      error_type = "notfound"
      error = "Nenhuma sacola ativa encontrada."
    }
  
    // Start the transaction to finalize the order
    db.transaction {
      stack {
        // Create the order (pedido)
        db.add pedido {
          enforce_hidden_fields = false
          data = {
            created_at      : "now"
            numero          : "PED-PENDING"
            total           : $sacola.total
            cliente_id      : $cliente.id
            status_pedido_id: 1
          }
        } as $pedido
      
        // Generate a readable order number
        db.edit pedido {
          field_name = "id"
          field_value = $pedido.id
          enforce_hidden_fields = false
          data = {numero: "PED-" ~ ($pedido.id|to_text)}
        } as $updated_pedido
      
        // Fetch items from the sacola
        db.query sacola_item {
          where = $db.sacola_item.sacola_id == $sacola.id
          return = {type: "list"}
        } as $sacola_items
      
        precondition (($sacola_items|count) > 0) {
          error_type = "accessdenied"
          error = "A sacola está vazia."
        }
      
        // Migrate items to the order
        var $item_nro {
          value = 1
        }
      
        foreach ($sacola_items) {
          each as $s_item {
            db.add item {
              enforce_hidden_fields = false
              data = {
                created_at    : "now"
                pedido_id     : $pedido.id
                nro           : $item_nro
                qtd           : $s_item.qtd
                valor_unit    : $s_item.valor_unit
                subtotal      : $s_item.subtotal
                produto_id    : $s_item.produto_id
                status_item_id: 1
              }
            } as $item_pedido
          
            var.update $item_nro {
              value = $item_nro + 1
            }
          
            // Migrate personalizations for each item
            db.query sacola_item_personalizacao {
              where = $db.sacola_item_personalizacao.sacola_item_id == $s_item.id
              return = {type: "list"}
            } as $s_personalizacoes
          
            conditional {
              if (($s_personalizacoes|count) > 0) {
                foreach ($s_personalizacoes) {
                  each as $s_p {
                    db.add item_personalizacao {
                      enforce_hidden_fields = false
                      data = {
                        created_at                     : "now"
                        item_id                        : $item_pedido.id
                        produto_personalizacao_id      : $s_p.produto_personalizacao_id
                        produto_personalizacao_opcao_id: $s_p.produto_personalizacao_opcao_id
                        valor_adicional                : $s_p.valor_adicional
                        observacao                     : $s_p.observacao
                      }
                    } as $new_personalizacao
                  }
                }
              }
            }
          }
        }
      
        // Mark sacola as finalized (status 2)
        db.edit sacola {
          field_name = "id"
          field_value = $sacola.id
          enforce_hidden_fields = false
          data = {status_sacola_id: 2}
        } as $finalized_sacola
      }
    }
  }

  response = {success: true, pedido: $updated_pedido}
  guid = "Wgp-DWvFdg99tuiP9ZRuBSyTIis"
}