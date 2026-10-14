// Delete verification_code record.
query "verification_code/{verification_code_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int verification_code_id? filters=min:1
  }

  stack {
    db.del verification_code {
      field_name = "id"
      field_value = $input.verification_code_id
    }
  }

  response = null
  guid = "qveSJBv6Ih_yF3pnUsifT9mW21g"
}