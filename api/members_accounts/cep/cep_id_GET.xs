// Get cep record
query "cep/{cep_id}" verb=GET {
  api_group = "Members & Accounts"

  input {
    int cep_id? filters=min:1
  }

  stack {
    db.get cep {
      field_name = "id"
      field_value = $input.cep_id
    } as $cep
  
    precondition ($cep != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $cep
  guid = "sN8c12n-8CHczLzR1Swgfe2q-fo"
}