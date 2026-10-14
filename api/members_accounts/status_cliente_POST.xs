// Add status_cliente record
query status_cliente verb=POST {
  api_group = "Members & Accounts"

  input {
    dblink {
      table = "status_cliente"
    }
  }

  stack {
    db.add status_cliente {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $status_cliente
  }

  response = $status_cliente
  guid = "RgNQEMcnboS8DfOb5lusKdEtl4U"
}