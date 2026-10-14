// Add sacola record
query sacola verb=POST {
  api_group = "Endereços"

  input {
    dblink {
      table = "sacola"
    }
  }

  stack {
    db.add sacola {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $sacola
  }

  response = $sacola
  guid = "MeDZGd8pomkTqsxmFL5E8XOHgFQ"
}