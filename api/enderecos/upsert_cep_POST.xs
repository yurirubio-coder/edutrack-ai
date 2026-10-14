query upsertCEP verb=POST {
  api_group = "Endereços"

  input {
    text cep filters=trim
    text cidade filters=trim
    text estado filters=trim
  }

  stack {
    db.query cep {
      where = $db.cep.cep == $input.cep
      return = {type: "single"}
    } as $cep1
  
    conditional {
      if ($cep1 != null) {
        db.patch cep {
          field_name = "id"
          field_value = $cep1.id
          data = {
            cep   : $input.cep
            cidade: $input.cidade
            estado: $input.estado
          }
        } as $cep2
      }
    
      else {
        db.add cep {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            cep       : $input.cep
            cidade    : $input.cidade
            estado    : $input.estado
          }
        } as $cep2
      }
    }
  }

  response = $cep2
  guid = "YoyFJnw00Vlz-wt8bVNWMtVxsNk"
}