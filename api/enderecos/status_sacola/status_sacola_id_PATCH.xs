// Edit status_sacola record
query "status_sacola/{status_sacola_id}" verb=PATCH {
  api_group = "Endereços"

  input {
    int status_sacola_id? filters=min:1
    dblink {
      table = "status_sacola"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch status_sacola {
      field_name = "id"
      field_value = $input.status_sacola_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $status_sacola
  }

  response = $status_sacola
  guid = "ozZ9NEJpxUUu9ejxDeM6yC5W7AY"
}