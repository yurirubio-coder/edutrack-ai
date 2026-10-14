// Get verification_code record
query "verification_code/{verification_code_id}" verb=GET {
  api_group = "Authentication"

  input {
    int verification_code_id? filters=min:1
  }

  stack {
    db.get verification_code {
      field_name = "id"
      field_value = $input.verification_code_id
    } as $verification_code
  
    precondition ($verification_code != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $verification_code
  guid = "y8ZzH0doRox7UMVYdlVfDb3OEfY"
}