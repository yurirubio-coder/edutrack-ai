// Get endereco record
query "endereco/{endereco_id}" verb=GET {
  api_group = "Members & Accounts"

  input {
    int endereco_id? filters=min:1
  }

  stack {
    db.get endereco {
      field_name = "id"
      field_value = $input.endereco_id
    } as $endereco
  
    precondition ($endereco != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $endereco
  guid = "JcGQjZ6UF1uSQ6Afcc9idRea9Rc"
}