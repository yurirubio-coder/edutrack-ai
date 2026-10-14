table op {
  auth = false

  schema {
    int id
  
    // essa coluna substitui "tempo_chegada", "data_hora_reg" e "data_hora"
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // número da ordem de produção
    text nop? filters=trim
  
    int pedido_id? {
      table = "pedido"
    }
  
    int status_op_id? {
      table = "status_op"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "F9dn71O84lI2YocDfL58Eh__2lY"
}