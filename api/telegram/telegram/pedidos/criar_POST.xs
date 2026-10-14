query "telegram/pedidos/criar" verb=POST {
  api_group = "Telegram"

  input {
    int produto_id
    int qtd
    int cliente_id?
    text endereco?
    text forma_pagamento?
    text observacao?
  }

  stack {
    // 1) Valida quantidade
    precondition ($input.qtd > 0) {
      error_type = "badrequest"
      error = "A quantidade precisa ser maior que zero."
    }
  
    // 2) Busca produto
    db.get produto {
      field_name = "id"
      field_value = $input.produto_id
    } as $produto
  
    precondition ($produto != null && $produto.ativo) {
      error_type = "notfound"
      error = "Produto não encontrado ou indisponível."
    }
  
    // 3) Verifica estoque disponível
    precondition ($produto.qtd_disp >= $input.qtd) {
      error_type = "badrequest"
      error = "Quantidade indisponível em estoque."
    }
  
    // 4) Define cliente padrão para o bot, caso o N8N não envie cliente_id
    var $cliente_id_final {
      value = 105
    }
  
    conditional {
      if ($input.cliente_id != null) {
        var.update $cliente_id_final {
          value = $input.cliente_id
        }
      }
    }
  
    db.get cliente {
      field_name = "id"
      field_value = $cliente_id_final
    } as $cliente
  
    precondition ($cliente != null) {
      error_type = "notfound"
      error = "Cliente não encontrado."
    }
  
    // 5) Define valor unitário considerando promoção
    var $valor_unit {
      value = $produto.preco
    }
  
    conditional {
      if ($produto.em_promocao && $produto.preco_promocional != null && $produto.preco_promocional > 0) {
        var.update $valor_unit {
          value = $produto.preco_promocional
        }
      }
    }
  
    var $subtotal {
      value = $valor_unit * $input.qtd
    }
  
    var $desconto {
      value = 0
    }
  
    var $total {
      value = $subtotal - $desconto
    }
  
    // 6) IDs padrão de status
    // Ajuste conforme sua tabela status_pedido.
    // Exemplo:
    // 1 = Novo
    var $status_pedido_novo_id {
      value = 1
    }
  
    // Ajuste conforme sua tabela status_item.
    // Exemplo:
    // 1 = Pendente/Novo
    var $status_item_novo_id {
      value = 1
    }
  
    // 7) Cria pedido temporário
    db.add pedido {
      enforce_hidden_fields = false
      data = {
        created_at      : "now"
        numero          : "PED-TMP"
        cliente_id      : $cliente.id
        subtotal        : $subtotal
        desconto        : $desconto
        total           : $total
        status_pedido_id: $status_pedido_novo_id
        observacao      : $input.observacao
        endereco_entrega: $input.endereco
        forma_pagamento : $input.forma_pagamento
      }
    } as $pedido
  
    // 8) Gera número legível usando o ID criado
    var $numero_pedido {
      value = "PED-" ~ $pedido.id
    }
  
    db.edit pedido {
      field_name = "id"
      field_value = $pedido.id
      enforce_hidden_fields = false
      data = {numero: $numero_pedido}
    } as $pedido_atualizado
  
    // 9) Cria item do pedido
    db.add item {
      enforce_hidden_fields = false
      data = {
        created_at    : "now"
        nro           : 1
        pedido_id     : $pedido_atualizado.id
        produto_id    : $produto.id
        qtd           : $input.qtd
        valor_unit    : $valor_unit
        subtotal      : $subtotal
        observacao    : $input.observacao
        status_item_id: $status_item_novo_id
      }
    } as $item
  
    // 10) Atualiza estoque e quantidade vendida
    db.edit produto {
      field_name = "id"
      field_value = $produto.id
      enforce_hidden_fields = false
      data = {
        qtd_disp   : $produto.qtd_disp - $input.qtd
        qtd_vendida: $produto.qtd_vendida + $input.qtd
      }
    } as $produto_atualizado
  
    // 11) Enriquecimento da resposta
    db.get status_pedido {
      field_name = "id"
      field_value = $pedido_atualizado.status_pedido_id
    } as $status_pedido
  
    var.update $item {
      value = $item
        |set:"produto":$produto_atualizado
    }
  
    var.update $pedido_atualizado {
      value = $pedido_atualizado
        |set:"cliente":$cliente
        |set:"status_pedido":$status_pedido
        |set:"items":```
          [
                    $item
                  ]
          ```
    }
  }

  response = {
    success: true
    message: "Pedido criado com sucesso pelo Telegram."
    pedido : $pedido_atualizado
  }

  guid = "svtAeSux85kCu2ov-GON4B24fhg"
}