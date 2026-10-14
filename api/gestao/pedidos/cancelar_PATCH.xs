query "pedidos/cancelar" verb=PATCH {
  api_group = "Gestão"
  auth = "user"

  input {
    int pedido_id
    text motivo
    int status_cancelado_id
    int status_solcancelamento_id
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
  
    precondition ($auth_papel.name == "Admin" || $auth_papel.name == "Atendente") {
      error_type = "accessdenied"
      error = "Você não tem permissão para cancelar pedidos."
    }
  
    db.get pedido {
      field_name = "id"
      field_value = $input.pedido_id
    } as $pedido
  
    precondition ($pedido != null) {
      error_type = "notfound"
      error = "Pedido não encontrado."
    }
  
    db.get status_pedido {
      field_name = "id"
      field_value = $input.status_cancelado_id
    } as $status_cancelado
  
    precondition ($status_cancelado != null) {
      error_type = "notfound"
      error = "Status cancelado inválido."
    }
  
    db.get status_solcancelamento {
      field_name = "id"
      field_value = $input.status_solcancelamento_id
    } as $status_solicitacao
  
    precondition ($status_solicitacao != null) {
      error_type = "notfound"
      error = "Status da solicitação de cancelamento inválido."
    }
  
    db.add solcancelamento {
      enforce_hidden_fields = false
      data = {
        created_at               : "now"
        numero                   : "CANCEL-" ~ $pedido.numero
        motivo                   : $input.motivo
        pedido_id                : $pedido.id
        status_solcancelamento_id: $input.status_solcancelamento_id
      }
    } as $solcancelamento
  
    db.edit pedido {
      field_name = "id"
      field_value = $pedido.id
      enforce_hidden_fields = false
      data = {status_pedido_id: $input.status_cancelado_id}
    } as $pedido_atualizado
  
    var.update $pedido_atualizado {
      value = $pedido_atualizado
        |set:"status_pedido":$status_cancelado
        |set:"solcancelamento":$solcancelamento
    }
  }

  response = {
    success: true
    message: "Pedido cancelado com sucesso."
    pedido : $pedido_atualizado
  }

  guid = "b6qJjdTyBreDL3UOnJn0oxQd7ZE"
}