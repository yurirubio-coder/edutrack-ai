// Edit endereco record
query "endereco/{endereco_id}" verb=PATCH {
  api_group = "Members & Accounts"

  input {
    int endereco_id? filters=min:1
    dblink {
      table = "endereco"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch endereco {
      field_name = "id"
      field_value = $input.endereco_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $endereco
  }

  response = $endereco
  guid = "yw3Z5PTr47mT-70kisbrhB6nWBk"
}