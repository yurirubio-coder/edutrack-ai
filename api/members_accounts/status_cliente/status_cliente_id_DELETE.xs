// Delete status_cliente record.
query "status_cliente/{status_cliente_id}" verb=DELETE {
  api_group = "Members & Accounts"

  input {
    int status_cliente_id? filters=min:1
  }

  stack {
    db.del status_cliente {
      field_name = "id"
      field_value = $input.status_cliente_id
    }
  }

  response = null
  guid = "KTQomLk32j1lcSGyndXTc5btOLw"
}