// Query all sacola_item records
query sacola_item verb=GET {
  api_group = "Endereços"

  input {
  }

  stack {
    db.query sacola_item {
      return = {type: "list"}
    } as $sacola_item
  }

  response = $sacola_item
  guid = "L79nIFq6ewXVb8c3hhRQFh8z_9U"
}