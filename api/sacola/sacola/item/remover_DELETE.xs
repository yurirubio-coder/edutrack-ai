query "sacola/item/remover" verb=DELETE {
  api_group = "sacola"
  auth = "user"

  input {
    int sacola_item_id
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
  
    precondition ($sacola != null) {
      error_type = "notfound"
      error = "Sacola ativa não encontrada."
    }
  
    db.get sacola_item {
      field_name = "id"
      field_value = $input.sacola_item_id
    } as $item
  
    precondition ($item != null && $item.sacola_id == $sacola.id) {
      error_type = "notfound"
      error = "Item não encontrado na sacola."
    }
  
    db.query sacola_item_personalizacao {
      where = $db.sacola_item_personalizacao.sacola_item_id == $item.id
      return = {type: "list"}
    } as $personalizacoes
  
    conditional {
      if (($personalizacoes|count) > 0) {
        foreach ($personalizacoes) {
          each as $personalizacao_item {
            db.del sacola_item_personalizacao {
              field_name = "id"
              field_value = $personalizacao_item.id
            }
          }
        }
      }
    }
  
    db.del sacola_item {
      field_name = "id"
      field_value = $item.id
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

  response = {success: true, sacola: $sacola_atualizada}
  guid = "44TxU5hGI_O4rFL3e5JxPqziEXU"
}