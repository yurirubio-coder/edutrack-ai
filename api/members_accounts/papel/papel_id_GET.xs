// Get papel record
query "papel/{papel_id}" verb=GET {
  api_group = "Members & Accounts"

  input {
    int papel_id? filters=min:1
  }

  stack {
    db.get papel {
      field_name = "id"
      field_value = $input.papel_id
    } as $papel
  
    precondition ($papel != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $papel
  guid = "dvEgzhqWbavGSc3qvN_h4g6_RX0"
}