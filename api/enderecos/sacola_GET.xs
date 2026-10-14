// Query all sacola records
query sacola verb=GET {
  api_group = "Endereços"

  input {
  }

  stack {
    db.query sacola {
      return = {type: "list"}
    } as $sacola
  }

  response = $sacola
  guid = "Ps45T2tnXH-ctmNBulSYcq6sPbA"
}