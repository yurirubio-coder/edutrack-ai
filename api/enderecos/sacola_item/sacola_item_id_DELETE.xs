// Delete sacola_item record.
query "sacola_item/{sacola_item_id}" verb=DELETE {
  api_group = "Endereços"

  input {
    int sacola_item_id? filters=min:1
  }

  stack {
    db.del sacola_item {
      field_name = "id"
      field_value = $input.sacola_item_id
    }
  }

  response = null
  guid = "hhNUjPrjblsQd_YbPUsfSEP7atE"
}