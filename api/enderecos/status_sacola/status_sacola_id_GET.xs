// Get status_sacola record
query "status_sacola/{status_sacola_id}" verb=GET {
  api_group = "Endereços"

  input {
    int status_sacola_id? filters=min:1
  }

  stack {
    db.get status_sacola {
      field_name = "id"
      field_value = $input.status_sacola_id
    } as $status_sacola
  
    precondition ($status_sacola != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $status_sacola
  guid = "OfR86A6f5dLURpTxbNm7ojJafb8"
}