// Add cep record
query cep verb=POST {
  api_group = "Members & Accounts"

  input {
    dblink {
      table = "cep"
    }
  }

  stack {
    // Insere um novo registro na tabela 'cep'
    db.add cep {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        cep       : $input.cep
        cidade    : $input.cidade
        estado    : $input.estado
      }
    } as $cep
  }

  response = $cep
  guid = "Svbn3fBLu9mkemnnoPqrahLinqE"
}