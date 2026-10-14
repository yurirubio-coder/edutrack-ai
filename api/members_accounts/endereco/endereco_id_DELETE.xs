// Delete endereco record.
query "endereco/{endereco_id}" verb=DELETE {
  api_group = "Members & Accounts"

  input {
    int endereco_id? filters=min:1
  }

  stack {
    db.del endereco {
      field_name = "id"
      field_value = $input.endereco_id
    }
  }

  response = null
  guid = "ki9BaPBkoxb3W_h0BlwcMSte6Rs"
}