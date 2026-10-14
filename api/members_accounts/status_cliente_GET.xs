// Query all status_cliente records
query status_cliente verb=GET {
  api_group = "Members & Accounts"

  input {
  }

  stack {
    db.query status_cliente {
      return = {type: "list"}
    } as $status_cliente
  }

  response = $status_cliente
  guid = "UIw4g_HvVmMrEmn6kCoFuhn0kVw"
}