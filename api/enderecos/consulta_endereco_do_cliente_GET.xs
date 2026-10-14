query consultaEnderecoDoCliente verb=GET {
  api_group = "Endereços"

  input {
    // ID do cliente para consulta de endereços
    int cliente_id
  }

  stack {
    // Busca todos os endereços associados ao cliente_id fornecido
    db.query endereco {
      where = $db.endereco.cliente_id == $input.cliente_id
      return = {type: "list"}
    } as $enderecos
  
    var $result_obj {
      value = {}
    }
  
    var $index {
      value = 1
    }
  
    // Itera sobre cada endereço para anexar as informações do CEP correspondente
    foreach ($enderecos) {
      each as $endereco_item {
        // Busca os detalhes do CEP para o endereço atual
        db.get cep {
          field_name = "id"
          field_value = $endereco_item.cep_id
        } as $cep_item
      
        // Constrói o objeto do endereço formatado com os dados do CEP incluídos
        var $formatted_endereco {
          value = {
            id         : $endereco_item.id
            created_at : $endereco_item.created_at
            cliente_id : $endereco_item.cliente_id
            logradouro : $endereco_item.logradouro
            numero     : $endereco_item.numero
            complemento: $endereco_item.complemento
            referencia : $endereco_item.referencia
            padrao     : $endereco_item.padrao
            _cep       : {
              id         : $cep_item.id
              created_at : $cep_item.created_at
              cep        : $cep_item.cep
              cidade     : $cep_item.cidade
              estado     : $cep_item.estado
            }
          }
        }
      
        // Gera uma chave dinâmica para o objeto de retorno (ex: endereco1, endereco2...)
        var $dynamic_key {
          value = "endereco" ~ ($index|to_text)
        }
      
        // Adiciona o endereço formatado ao objeto de resultado final
        var.update $result_obj {
          value = $result_obj
            |set:$dynamic_key:[$formatted_endereco]
        }
      
        // Incrementa o índice para o próximo endereço
        var.update $index {
          value = $index + 1
        }
      }
    }
  }

  response = $result_obj
  guid = "AU3b8daIQIow8egZVzM0Rj5-_YU"
}