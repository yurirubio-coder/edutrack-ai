// Add papel record
query papel verb=POST {
  api_group = "Members & Accounts"

  input {
    dblink {
      table = "papel"
    }
  }

  stack {
    db.add papel {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $papel
  }

  response = $papel
  guid = "0ckNUShBWMq2UJKnbIMxLnTb_Bk"
}