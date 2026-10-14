// Query all verification_code records
query verification_code verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query verification_code {
      return = {type: "list"}
    } as $verification_code
  }

  response = $verification_code
  guid = "FaMrEE_G5XbPwI0G8bAQtNHpaRA"
}