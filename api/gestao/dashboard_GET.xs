// API que retorna métricas iniciais para montar o dashboard
query dashboard verb=GET {
  api_group = "Gestão"
  auth = "user"

  input {
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
      error = "Sem permissão para acessar o painel."
    }
  
    db.query pedido {
      return = {type: "list"}
    } as $pedidos
  
    db.query produto {
      return = {type: "list"}
    } as $produtos
  
    db.query cliente {
      return = {type: "list"}
    } as $clientes
  
    db.query pedido {
      sort = {created_at: "desc"}
      return = {type: "list"}
    } as $pedidos_recentes
  
    var $total_faturamento {
      value = 0
    }
  
    conditional {
      if (($pedidos|count) > 0) {
        foreach ($pedidos) {
          each as $pedido_item {
            var.update $total_faturamento {
              value = $total_faturamento + $pedido_item.total
            }
          }
        }
      }
    }
  
    var $ticket_medio {
      value = 0
    }
  
    conditional {
      if (($pedidos|count) > 0) {
        var.update $ticket_medio {
          value = $total_faturamento / ($pedidos|count)
        }
      }
    }
  }

  response = {
    total_pedidos    : $pedidos|count
    total_produtos   : $produtos|count
    total_clientes   : $clientes|count
    total_faturamento: $total_faturamento
    ticket_medio     : $ticket_medio
    pedidos_recentes : $pedidos_recentes
  }

  guid = "_Oyq79WktdTTm6ca3iynosu0dMA"
}