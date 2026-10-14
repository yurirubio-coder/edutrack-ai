// Get status_cliente record
query "status_cliente/{status_cliente_id}" verb=GET {
  api_group = "Members & Accounts"

  input {
    int status_cliente_id? filters=min:1
  }

  stack {
    db.get status_cliente {
      field_name = "id"
      field_value = $input.status_cliente_id
    } as $status_cliente
  
    precondition ($status_cliente != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $status_cliente
  guid = "cHKgHrRPL1Y64jgSDTbMJxNHc8M"
}