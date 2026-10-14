query "pedidos/status" verb=PATCH {
  api_group = "Gestão"
  auth = "user"

  input {
    int pedido_id
    int status_pedido_id
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
      error = "Você não tem permissão para atualizar pedidos."
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
      field_value = $input.status_pedido_id
    } as $novo_status
  
    precondition ($novo_status != null) {
      error_type = "notfound"
      error = "Status de pedido inválido."
    }
  
    db.edit pedido {
      field_name = "id"
      field_value = $input.pedido_id
      enforce_hidden_fields = false
      data = {status_pedido_id: $input.status_pedido_id}
    } as $pedido_atualizado
  
    db.get cliente {
      field_name = "id"
      field_value = $pedido_atualizado.cliente_id
    } as $cliente
  
    var.update $pedido_atualizado {
      value = $pedido_atualizado
        |set:"cliente":$cliente
        |set:"status_pedido":$novo_status
    }
  }

  response = {
    success: true
    message: "Status do pedido atualizado com sucesso."
    pedido : $pedido_atualizado
  }

  guid = "e5VYh0bbvytI6yxn4HQPxhUd_yE"
}