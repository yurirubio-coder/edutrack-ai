table solcancelamento {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text numero? filters=trim
    text motivo? filters=trim
    int pedido_id? {
      table = "pedido"
    }
  
    int status_solcancelamento_id? {
      table = "status_solcancelamento"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "bHsqc-lybr-aA4-gGHHRUWyu5lE"
}