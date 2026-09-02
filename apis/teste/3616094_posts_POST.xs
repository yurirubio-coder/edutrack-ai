// Add posts record
query posts verb=POST {
  api_group = "teste"

  input {
    dblink {
      table = "posts"
    }
  }

  stack {
    db.add posts {
      enforce_hidden_fields = false
      data = {created_at: "now", body: $input.body}
    } as $model
  }

  response = $model
}