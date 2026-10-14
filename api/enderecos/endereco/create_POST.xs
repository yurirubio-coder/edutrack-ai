query "endereco/create" verb=POST {
  api_group = "Endereços"
  auth = "user"

  input {
    text cep
    text logradouro
    text numero
    text complemento
    text referencia
    bool padrao
  }

  stack {
    precondition ($input.logradouro != null && $input.numero != null) {
      error = "Logradouro e número obrigatórios."
    }
  
    db.get cliente {
      field_name = "user_id"
      field_value = $auth.id
    } as $cliente
  
    precondition ($cliente != null) {
      error_type = "accessdenied"
      error = "Cliente não encontrado"
    }
  
    db.get cep {
      field_name = "cep"
      field_value = $input.cep
    } as $cep_record
  
    conditional {
      if ($cep_record == null) {
        db.add cep {
          enforce_hidden_fields = false
          data = {created_at: "now", cep: $input.cep}
        } as $cep_record
      }
    }
  
    conditional {
      if ($input.padrao) {
        db.query endereco {
          where = $db.endereco.cliente_id == $cliente.id
          return = {type: "list"}
        } as $enderecos
      
        conditional {
          if (($enderecos|count) > 0) {
            db.bulk.update endereco {
              items = $enderecos
                |lambda_map:"{id: x.id, padrao: false}":10
            }
          }
        }
      }
    }
  
    db.add endereco {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        cliente_id : $cliente.id
        logradouro : $input.logradouro
        numero     : $input.numero
        complemento: $input.complemento
        referencia : $input.referencia
        padrao     : $input.padrao
        cep_id     : $cep_record.id
      }
    } as $new_endereco
  }

  response = $new_endereco
  tags = ["information"]
  guid = "Wd0BIWanx4ShOA1GpyPH5larnPE"
}