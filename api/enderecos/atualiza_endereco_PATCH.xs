// Salva ou atualiza o CEP e o endereço do cliente.
// Retorna o resultado em um objeto com chave dinâmica 'result2_ID'.
// Retorna o objeto formatado
// Salva um novo endereço para o cliente ou atualiza um existente, formatando a resposta com uma chave dinâmica.
query atualizaEndereco verb=PATCH {
  api_group = "Endereços"

  input {
    // Logradouro do endereço
    text logradouro
  
    // Número do endereço
    text numero
  
    // Complemento opcional
    text complemento?
  
    // Ponto de referência opcional
    text referencia?
  
    // CEP (somente números ou formatado)
    text cep
  
    // Nome da cidade
    text cidade
  
    // Sigla ou nome do estado
    text estado
  
    // Define se este é o endereço padrão do cliente
    bool padrao
  
    // ID do cliente associado ao endereço
    int cliente_id
  }

  stack {
    // 1. Salva ou atualiza os dados do CEP na tabela 'cep'
    // Se o CEP já existir, atualiza cidade e estado.
    db.add_or_edit cep {
      field_name = "cep"
      field_value = $input.cep
      enforce_hidden_fields = false
      data = {
        cep   : $input.cep
        cidade: $input.cidade
        estado: $input.estado
      }
    } as $cep_record
  
    // 2. Busca se já existe um endereço para este cliente com o mesmo logradouro e número
    db.query endereco {
      where = $db.endereco.cliente_id == $input.cliente_id && $db.endereco.logradouro == $input.logradouro && $db.endereco.numero == $input.numero
      return = {type: "single"}
    } as $existing_endereco
  
    // 3. Salva (Cria) ou Atualiza o registro na tabela 'endereco'
    conditional {
      if ($existing_endereco != null) {
        // Atualiza os demais campos no endereço existente
        db.patch endereco {
          field_name = "id"
          field_value = $existing_endereco.id
          data = {
            complemento: $input.complemento
            referencia : $input.referencia
            padrao     : $input.padrao
            cep_id     : $cep_record.id
          }
        } as $endereco
      }
    
      else {
        // Cria um novo registro de endereço
        db.add endereco {
          enforce_hidden_fields = false
          data = {
            cliente_id : $input.cliente_id
            logradouro : $input.logradouro
            numero     : $input.numero
            complemento: $input.complemento
            referencia : $input.referencia
            padrao     : $input.padrao
            cep_id     : $cep_record.id
            created_at : "now"
          }
        } as $endereco
      }
    }
  
    // 4. Constrói o objeto interno de retorno com os dados do endereço e CEP
    var $inner_data {
      value = {
        logradouro : $endereco.logradouro
        numero     : $endereco.numero
        complemento: $endereco.complemento
        referencia : $endereco.referencia
        padrao     : $endereco.padrao
        cliente_id : $endereco.cliente_id
        cep        : {
          cep_id: $cep_record.id,
          cidade: $cep_record.cidade,
          estado: $cep_record.estado
        }
      }
    }
  
    // 5. Define a chave dinâmica 'result2_' seguido do ID do endereço
    var $key {
      value = "result2_" ~ ($endereco.id|to_text)
    }
  
    // 6. Monta o objeto final de resposta
    var $final_response {
      value = {}|set:$key:$inner_data
    }
  }

  response = $final_response
  guid = "70MIx-fywx1dYRw-oJ85MgseF4A"
}