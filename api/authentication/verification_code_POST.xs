// Add verification_code record
query verification_code verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "verification_code"
    }
  }

  stack {
    db.add verification_code {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $verification_code
  }

  response = $verification_code
  guid = "G0FbyiXsb57QaqBRjR1ExztUgqU"
}