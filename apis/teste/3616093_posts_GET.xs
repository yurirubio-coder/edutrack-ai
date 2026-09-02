// Query all posts records
query posts verb=GET {
  api_group = "teste"

  input {
  }

  stack {
    db.query posts {
      return = {type: "list"}
    } as $model
  }

  response = $model
}