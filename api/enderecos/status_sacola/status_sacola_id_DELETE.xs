// Delete status_sacola record.
query "status_sacola/{status_sacola_id}" verb=DELETE {
  api_group = "Endereços"

  input {
    int status_sacola_id? filters=min:1
  }

  stack {
    db.del status_sacola {
      field_name = "id"
      field_value = $input.status_sacola_id
    }
  }

  response = null
  guid = "ik-GjtLqVGTLSakOj54nJoIU2Bg"
}