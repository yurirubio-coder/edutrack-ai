// Get posts record
query "posts/{posts_id}" verb=GET {
  api_group = "teste"

  input {
    int posts_id? filters=min:1
  }

  stack {
    db.get posts {
      field_name = "id"
      field_value = $input.posts_id
    } as $model
  
    precondition ($model != null) {
      error_type = "notfound"
      error = "Not Found"
    }
  }

  response = $model
}