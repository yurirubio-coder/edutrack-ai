// Add subjects record for authenticated user
query subjects verb=POST {
  api_group = "College"
  auth = "user"

  input {
    text name filters=trim
    text? description? filters=trim
    text? code? filters=trim
  }

  stack {
    db.add subjects {
      data = {
        name       : $input.name
        description: $input.description
        code       : $input.code
        user_id    : $auth.id
        created_at : "now"
      }
    } as $subject
  }

  response = $subject
  guid = "nJzaUjeFsVB4GfHNPmpgJigvnxk"
}

