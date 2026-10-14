query pedidos verb=GET {
  api_group = "Gestão"
  auth = "user"

  input {
    int status_pedido_id?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $auth_user
  
    db.get papel {
      field_name = "id"
      field_value = $auth_user.papel_id
    } as $auth_papel
  
    precondition ($auth_papel.name == "Admin" || $auth_papel.name == "Atendente" || $auth_papel.name == "Cozinheiro") {
      error_type = "accessdenied"
      error = "Você não tem permissão para visualizar pedidos."
    }
  
    conditional {
      if ($input.status_pedido_id != null) {
        db.query pedido {
          where = $db.pedido.status_pedido_id == $input.status_pedido_id
          sort = {created_at: "desc"}
          return = {type: "list"}
        } as $pedidos
      }
    
      else {
        db.query pedido {
          sort = {created_at: "desc"}
          return = {type: "list"}
        } as $pedidos
      }
    }
  
    foreach ($pedidos) {
      each as $pedido_item {
        db.get cliente {
          field_name = "id"
          field_value = $pedido_item.cliente_id
        } as $cliente
      
        db.get status_pedido {
          field_name = "id"
          field_value = $pedido_item.status_pedido_id
        } as $status_pedido
      
        db.query item {
          where = $db.item.pedido_id == $pedido_item.id
          sort = {nro: "asc", id: "asc"}
          return = {type: "list"}
        } as $items
      
        foreach ($items) {
          each as $item_pedido {
            db.get produto {
              field_name = "id"
              field_value = $item_pedido.produto_id
            } as $produto
          
            db.get status_item {
              field_name = "id"
              field_value = $item_pedido.status_item_id
            } as $status_item
          
            var.update $item_pedido {
              value = $item_pedido
                |set:"produto":$produto
                |set:"status_item":$status_item
            }
          }
        }
      
        var.update $pedido_item {
          value = $pedido_item
            |set:"cliente":$cliente
            |set:"status_pedido":$status_pedido
            |set:"items":$items
            |set:"quantidade_itens":($items|count)
        }
      }
    }
  }

  response = $pedidos
  guid = "ix_5qOWAke9LesfP6GCzkpLHCrc"
}