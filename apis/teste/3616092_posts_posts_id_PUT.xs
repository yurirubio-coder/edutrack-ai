// Update posts record
query "posts/{posts_id}" verb=PUT {
  api_group = "teste"

  input {
    int posts_id? filters=min:1
    dblink {
      table = "posts"
    }
  }

  stack {
    db.edit posts {
      field_name = "id"
      field_value = $input.posts_id
      enforce_hidden_fields = false
      data = {body: $input.body}
    } as $model
  }

  response = $model
}