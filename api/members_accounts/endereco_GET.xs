// Query all endereco records
query endereco verb=GET {
  api_group = "Members & Accounts"

  input {
  }

  stack {
    db.query endereco {
      return = {type: "list"}
    } as $endereco
  }

  response = $endereco
  guid = "DuIjWImYBr__zSflyPd3PDuY8KY"
}