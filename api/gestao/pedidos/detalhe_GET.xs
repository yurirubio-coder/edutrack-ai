query "pedidos/detalhe" verb=GET {
  api_group = "Gestão"

  input {
    int pedido_id
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
      error = "Você não tem permissão para visualizar detalhes de pedidos."
    }
  
    db.get pedido {
      field_name = "id"
      field_value = $input.pedido_id
    } as $pedido
  
    precondition ($pedido != null) {
      error_type = "notfound"
      error = "Pedido não encontrado."
    }
  
    db.get cliente {
      field_name = "id"
      field_value = $pedido.cliente_id
    } as $cliente
  
    db.get status_pedido {
      field_name = "id"
      field_value = $pedido.status_pedido_id
    } as $status_pedido
  
    db.query endereco {
      where = $db.endereco.cliente_id == $pedido.cliente_id && $db.endereco.padrao == true
      return = {type: "single"}
    } as $endereco
  
    conditional {
      if ($endereco != null) {
        db.get cep {
          field_name = "id"
          field_value = $endereco.cep_id
        } as $cep
      
        var.update $endereco {
          value = $endereco|set:"cep":$cep
        }
      }
    }
  
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
      
        db.get status_item {
          field_name = "id"
          field_value = $item_pedido.status_item_id
        } as $status_item
      
        db.query item_personalizacao {
          where = $db.item_personalizacao.item_id == $item_pedido.id
          return = {type: "list"}
        } as $personalizacoes
      
        foreach ($personalizacoes) {
          each as $personalizacao_item {
            db.get produto_personalizacao {
              field_name = "id"
              field_value = $personalizacao_item.produto_personalizacao_id
            } as $produto_personalizacao
          
            db.get produto_personalizacao_opcao {
              field_name = "id"
              field_value = $personalizacao_item.produto_personalizacao_opcao_id
            } as $produto_personalizacao_opcao
          
            var.update $personalizacao_item {
              value = $personalizacao_item
                |set:"personalizacao":$produto_personalizacao
                |set:"opcao":$produto_personalizacao_opcao
            }
          }
        }
      
        var.update $item_pedido {
          value = $item_pedido
            |set:"produto":$produto
            |set:"status_item":$status_item
            |set:"personalizacoes":$personalizacoes
        }
      }
    }
  
    var.update $pedido {
      value = $pedido
        |set:"cliente":$cliente
        |set:"status_pedido":$status_pedido
        |set:"endereco":$endereco
        |set:"items":$items
    }
  }

  response = $pedido
  guid = "8A19qgCc-7ChCz1emsABrqD71kA"
}