// Delete posts record
query "posts/{posts_id}" verb=DELETE {
  api_group = "teste"

  input {
    int posts_id? filters=min:1
  }

  stack {
    db.del posts {
      field_name = "id"
      field_value = $input.posts_id
    }
  }

  response = null
}