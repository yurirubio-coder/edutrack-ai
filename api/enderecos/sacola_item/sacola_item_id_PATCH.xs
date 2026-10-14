// Edit sacola_item record
query "sacola_item/{sacola_item_id}" verb=PATCH {
  api_group = "Endereços"

  input {
    int sacola_item_id? filters=min:1
    dblink {
      table = "sacola_item"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch sacola_item {
      field_name = "id"
      field_value = $input.sacola_item_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $sacola_item
  }

  response = $sacola_item
  guid = "GP5OGqjoh_l44K9pj3yXCRdM7qw"
}