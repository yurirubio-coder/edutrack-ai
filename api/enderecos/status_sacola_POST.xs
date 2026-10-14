// Add status_sacola record
query status_sacola verb=POST {
  api_group = "Endereços"

  input {
    dblink {
      table = "status_sacola"
    }
  }

  stack {
    db.add status_sacola {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $status_sacola
  }

  response = $status_sacola
  guid = "Kur6uj_s2KHTGGe3A_3x8v0HjYU"
}