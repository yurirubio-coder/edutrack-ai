// Query all posts records
query posts verb=GET {
  api_group = "Event Logs"

  input {
  }

  stack {
    db.query posts {
      return = {type: "list"}
    } as $posts
  }

  response = $posts
}