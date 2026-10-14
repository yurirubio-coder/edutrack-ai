// Delete papel record.
query "papel/{papel_id}" verb=DELETE {
  api_group = "Members & Accounts"

  input {
    int papel_id? filters=min:1
  }

  stack {
    db.del papel {
      field_name = "id"
      field_value = $input.papel_id
    }
  }

  response = null
  guid = "18jembMhbwK_TY5md0BpyoHG5zU"
}