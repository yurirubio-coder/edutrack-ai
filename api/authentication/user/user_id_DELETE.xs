// Endpoint to delete a user by their ID
query "user/{user_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    // The ID of the user to delete
    int user_id filters=min:1
  }

  stack {
    // Fetch the user first to verify existence
    db.get user {
      field_name = "id"
      field_value = $input.user_id
    } as $user
  
    // Ensure the user exists before attempting deletion
    precondition ($user != null) {
      error_type = "notfound"
      error = "Usuário não encontrado."
    }
  
    // Delete the user record from the database
    db.del user {
      field_name = "id"
      field_value = $input.user_id
    }
  }

  response = {success: true, deleted_user_id: $input.user_id}
  guid = "Tlnbg-SJlydj6lUjc6RARttfwt0"
}