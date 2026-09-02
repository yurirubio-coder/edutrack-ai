// Add posts record
query posts verb=POST {
  api_group = "Event Logs"

  input {
    dblink {
      table = "posts"
    }
  }

  stack {
    db.add posts {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $posts
  }

  response = $posts
}