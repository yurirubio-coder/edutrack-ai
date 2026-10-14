// Add sacola_item record
query sacola_item verb=POST {
  api_group = "Endereços"

  input {
    dblink {
      table = "sacola_item"
    }
  }

  stack {
    db.add sacola_item {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $sacola_item
  }

  response = $sacola_item
  guid = "FWC-c6jmpySOdbxEUQ-xSXufX10"
}