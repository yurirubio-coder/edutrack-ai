query "sacola/limpar" verb=POST {
  api_group = "sacola"
  auth = "user"

  input {
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
  
    db.query sacola_item {
      where = $db.sacola_item.sacola_id == $sacola.id
      return = {type: "list"}
    } as $itens
  
    conditional {
      if (($itens|count) > 0) {
        foreach ($itens) {
          each as $item {
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
          }
        }
      }
    }
  
    db.edit sacola {
      field_name = "id"
      field_value = $sacola.id
      enforce_hidden_fields = false
      data = {subtotal: 0, desconto: 0, total: 0}
    } as $sacola_atualizada
  }

  response = {success: true, sacola: $sacola_atualizada}
  guid = "xjM8FVMruUdMrcmJKxrbKxFMG3M"
}