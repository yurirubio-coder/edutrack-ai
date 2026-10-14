// Query all cliente records
query cliente verb=GET {
  api_group = "Members & Accounts"

  input {
  }

  stack {
    db.query cliente {
      return = {type: "list"}
    } as $cliente
  }

  response = $cliente
  guid = "LRKG8PlrvybmX6W3UtM8xVQXi6g"
}