table ttokenizacao {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int cliente_id? {
      table = "cliente"
    }
  
    text? det_cartao_encript? filters=trim
    int status_ttokenizacao_id? {
      table = "status_ttokenizacao"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "ciOGAa47p5ckqY3NwUxdFQOw3-g"
}