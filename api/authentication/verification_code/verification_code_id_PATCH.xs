// Edit verification_code record
query "verification_code/{verification_code_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int verification_code_id? filters=min:1
    dblink {
      table = "verification_code"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch verification_code {
      field_name = "id"
      field_value = $input.verification_code_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $verification_code
  }

  response = $verification_code
  guid = "CMMbe8COIQOqSQit9O935nuLFC8"
}