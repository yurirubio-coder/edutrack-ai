query "sacola/adicionar-item" verb=POST {
  api_group = "sacola"
  auth = "user"

  input {
    int produto_id
    int qtd
    text observacao?
    json personalizacoes?
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
  
    precondition ($input.qtd > 0) {
      error_type = "accessdenied"
      error = "Quantidade inválida."
    }
  
    db.get produto {
      field_name = "id"
      field_value = $input.produto_id
    } as $produto
  
    precondition ($produto != null && $produto.ativo) {
      error_type = "notfound"
      error = "Produto não encontrado."
    }
  
    precondition ($produto.qtd_disp >= $input.qtd) {
      error_type = "accessdenied"
      error = "Quantidade indisponível."
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
  
    var $preco_original {
      value = $produto.preco
    }
  
    var $preco_final {
      value = $produto.preco
    }
  
    conditional {
      if ($produto.em_promocao && $produto.preco_promocional != null) {
        var.update $preco_final {
          value = $produto.preco_promocional
        }
      }
    }
  
    var $adicionais_unitarios {
      value = 0
    }
  
    conditional {
      if ($input.personalizacoes != null && ($input.personalizacoes|count) > 0) {
        foreach ($input.personalizacoes) {
          each as $personalizacao_input {
            var $p_qtd {
              value = $personalizacao_input.qtd == null ? 1 : $personalizacao_input.qtd
            }
          
            var $p_valor {
              value = $personalizacao_input.valor_adicional == null ? 0 : $personalizacao_input.valor_adicional
            }
          
            var.update $adicionais_unitarios {
              value = $adicionais_unitarios + ($p_valor * $p_qtd)
            }
          }
        }
      }
    }
  
    var $valor_unit {
      value = $preco_final + $adicionais_unitarios
    }
  
    var $subtotal_item {
      value = $valor_unit * $input.qtd
    }
  
    db.add sacola_item {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        sacola_id : $sacola.id
        produto_id: $produto.id
        qtd       : $input.qtd
        valor_unit: $valor_unit
        subtotal  : $subtotal_item
        observacao: $input.observacao
      }
    } as $sacola_item
  
    conditional {
      if ($input.personalizacoes != null && ($input.personalizacoes|count) > 0) {
        foreach ($input.personalizacoes) {
          each as $personalizacao_input {
            db.add sacola_item_personalizacao {
              enforce_hidden_fields = false
              data = {
                created_at                     : "now"
                sacola_item_id                 : $sacola_item.id
                produto_personalizacao_id      : $personalizacao_input.produto_personalizacao_id
                produto_personalizacao_opcao_id: $personalizacao_input.produto_personalizacao_opcao_id
                valor_adicional                : $personalizacao_input.valor_adicional == null ? 0 : $personalizacao_input.valor_adicional
                qtd                            : $personalizacao_input.qtd == null ? 1 : $personalizacao_input.qtd
                observacao                     : $personalizacao_input.observacao
              }
            } as $sacola_item_personalizacao
          }
        }
      }
    }
  
    // Recalcular sacola
    db.query sacola_item {
      where = $db.sacola_item.sacola_id == $sacola.id
      return = {type: "list"}
    } as $itens_sacola
  
    var $total_final {
      value = 0
    }
  
    var $desconto_total {
      value = 0
    }
  
    conditional {
      if (($itens_sacola|count) > 0) {
        foreach ($itens_sacola) {
          each as $item_calc {
            var.update $total_final {
              value = $total_final + $item_calc.subtotal
            }
          
            db.get produto {
              field_name = "id"
              field_value = $item_calc.produto_id
            } as $produto_calc
          
            conditional {
              if ($produto_calc != null && $produto_calc.em_promocao && $produto_calc.preco_promocional != null) {
                var $desconto_unit {
                  value = $produto_calc.preco - $produto_calc.preco_promocional
                }
              
                var.update $desconto_total {
                  value = $desconto_total + ($desconto_unit * $item_calc.qtd)
                }
              }
            }
          }
        }
      }
    }
  
    var $subtotal_antes_desconto {
      value = $total_final + $desconto_total
    }
  
    db.edit sacola {
      field_name = "id"
      field_value = $sacola.id
      enforce_hidden_fields = false
      data = {
        subtotal: $subtotal_antes_desconto
        desconto: $desconto_total
        total   : $total_final
      }
    } as $sacola_atualizada
  }

  response = {
    success: true
    sacola : $sacola_atualizada
    item   : $sacola_item
  }

  guid = "f8SAFUcII5AbAPsmX_sl42szKMI"
}