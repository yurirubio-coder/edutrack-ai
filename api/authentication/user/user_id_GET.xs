query "user/{user_id}" verb=GET {
  api_group = "Authentication"

  input {
    int user_id filters=min:1
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $input.user_id
      output = ["id", "created_at", "name", "email", "papel_id"]
    } as $user
  
    precondition ($user != null) {
      error_type = "notfound"
      error = "Usuário não encontrado."
    }
  }

  response = $user
  guid = "U-cBNMEIEEQRNQGVY3Icyql8c00"
}