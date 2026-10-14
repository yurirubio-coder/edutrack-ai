// Query all cep records
query cep verb=GET {
  api_group = "Members & Accounts"

  input {
  }

  stack {
    db.query cep {
      return = {type: "list"}
    } as $cep
  }

  response = $cep
  guid = "9H7Kx3A-QgbEuDNZqFasUojE2OY"
}