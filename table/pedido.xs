table pedido {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text numero? filters=trim
    decimal total?
    text? nfc_e? filters=trim
    text? cod_entrega? filters=trim
    int cliente_id? {
      table = "cliente"
    }
  
    int status_pedido_id? {
      table = "status_pedido"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "M-N2Dz85Rl3mDCYq-PDqIXPpjYY"
}