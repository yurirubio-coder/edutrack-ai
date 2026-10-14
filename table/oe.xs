table oe {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // número da ordem de entrega
    text noe? filters=trim
  
    int pedido_id? {
      table = "pedido"
    }
  
    int status_oe_id? {
      table = "status_oe"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "LIvuVt3lGUigW623uX2A8SZnwMI"
}