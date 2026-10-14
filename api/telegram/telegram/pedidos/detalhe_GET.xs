query "telegram/pedidos/detalhe" verb=GET {
  api_group = "Telegram"

  input {
    int pedido_id
  }

  stack {
    db.get pedido {
      field_name = "id"
      field_value = $input.pedido_id
    } as $pedido
  
    conditional {
      if ($pedido == null) {
        var $resposta {
          value = {
            success: false
            found  : false
            message: "Pedido não encontrado. Confira o número informado e tente novamente."
          }
        }
      }
    
      else {
        db.get cliente {
          field_name = "id"
          field_value = $pedido.cliente_id
        } as $cliente
      
        db.get status_pedido {
          field_name = "id"
          field_value = $pedido.status_pedido_id
        } as $status_pedido
      
        db.query item {
          where = $db.item.pedido_id == $pedido.id
          sort = {nro: "asc", id: "asc"}
          return = {type: "list"}
        } as $items
      
        foreach ($items) {
          each as $item_pedido {
            db.get produto {
              field_name = "id"
              field_value = $item_pedido.produto_id
            } as $produto
          
            var.update $item_pedido {
              value = $item_pedido|set:"produto":$produto
            }
          }
        }
      
        var $status_nome {
          value = "Status não informado"
        }
      
        conditional {
          if ($status_pedido != null && $status_pedido.status != null) {
            var.update $status_nome {
              value = $status_pedido.status
            }
          }
        }
      
        var $cliente_nome {
          value = "Cliente"
        }
      
        conditional {
          if ($cliente != null && $cliente.name != null) {
            var.update $cliente_nome {
              value = $cliente.name
            }
          }
        }
      
        var $resumo_texto {
          value = "Pedido #" ~ $pedido.id ~ "\nStatus: " ~ $status_nome ~ "\nCliente: " ~ $cliente_nome ~ "\nTotal: R$ " ~ $pedido.total
        }
      
        var.update $pedido {
          value = $pedido
            |set:"cliente":$cliente
            |set:"status_pedido":$status_pedido
            |set:"items":$items
            |set:"quantidade_itens":($items|count)
            |set:"resumo_texto":$resumo_texto
        }
      
        var $resposta {
          value = {
            success: true
            found  : true
            message: "Pedido encontrado."
            pedido : $pedido
          }
        }
      }
    }
  }

  response = $resposta
  guid = "sK174EM42_fE1nEPmaM9UavJWoQ"
}