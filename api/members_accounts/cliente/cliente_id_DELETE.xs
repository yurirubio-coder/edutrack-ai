// Delete cliente record.
query "cliente/{cliente_id}" verb=DELETE {
  api_group = "Members & Accounts"

  input {
    int cliente_id? filters=min:1
  }

  stack {
    db.del cliente {
      field_name = "id"
      field_value = $input.cliente_id
    }
  }

  response = null
  guid = "BgHH86JQVSaHKW3v_0r4WOjVcgo"
}