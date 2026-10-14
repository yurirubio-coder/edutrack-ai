// Salva um novo endereço para o cliente e retorna no formato solicitado.
query salvaEndereco verb=POST {
  api_group = "Endereços"

  input {
    // Logradouro do endereço
    text logradouro
  
    // Número do endereço
    text numero
  
    // Complemento do endereço
    text complemento
  
    // Referência do endereço
    text referencia
  
    // CEP do endereço
    text cep
  
    // Cidade do endereço
    text cidade
  
    // Estado do endereço
    text estado
  
    // Define se é o endereço padrão
    bool padrao
  
    // ID do cliente associado
    int cliente_id
  }

  stack {
    // Garante que o registro de CEP exista na tabela 'cep'
    db.add_or_edit cep {
      field_name = "cep"
      field_value = $input.cep
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        cep       : $input.cep
        cidade    : $input.cidade
        estado    : $input.estado
      }
    } as $cep_record
  
    // Cria o novo registro de endereço vinculado ao cliente e ao CEP
    db.add endereco {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        cliente_id : $input.cliente_id
        logradouro : $input.logradouro
        numero     : $input.numero
        complemento: $input.complemento
        referencia : $input.referencia
        padrao     : $input.padrao
        cep_id     : $cep_record.id
      }
    } as $new_endereco
  
    // Monta o objeto de dados conforme o formato solicitado
    var $inner_result {
      value = {
        logradouro : $new_endereco.logradouro
        numero     : $new_endereco.numero
        complemento: $new_endereco.complemento
        referencia : $new_endereco.referencia
        padrao     : $new_endereco.padrao
        cliente_id : $new_endereco.cliente_id
        cep        : {
          cep_id : $cep_record.id
          cidade : $cep_record.cidade
          estado : $cep_record.estado
        }
      }
    }
  
    // Define a chave dinâmica 'result' + ID sequencial do novo endereço
    var $response_key {
      value = "result" ~ ($new_endereco.id|to_text)
    }
  
    // Cria o objeto final de resposta com a chave dinâmica
    var $final_response {
      value = {}|set:$response_key:$inner_result
    }
  }

  response = $final_response
  guid = "AwBfh14v3KCA3oP9XWsubtw2cOI"
}