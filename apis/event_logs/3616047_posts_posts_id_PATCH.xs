// Edit posts record
query "posts/{posts_id}" verb=PATCH {
  api_group = "Event Logs"

  input {
    int posts_id? filters=min:1
    dblink {
      table = "posts"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch posts {
      field_name = "id"
      field_value = $input.posts_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $posts
  }

  response = $posts
}