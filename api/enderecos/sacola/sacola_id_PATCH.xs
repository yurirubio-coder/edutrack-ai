// Edit sacola record
query "sacola/{sacola_id}" verb=PATCH {
  api_group = "Endereços"

  input {
    int sacola_id? filters=min:1
    dblink {
      table = "sacola"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch sacola {
      field_name = "id"
      field_value = $input.sacola_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $sacola
  }

  response = $sacola
  guid = "kbPZz0bdSkHZ4BAlYXGSNEHb0WQ"
}