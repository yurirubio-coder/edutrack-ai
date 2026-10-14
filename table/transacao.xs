table transacao {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text clienteassas? filters=trim
    text idpayment? filters=trim
    text tipo? filters=trim
    text valor? filters=trim
    text datavenc? filters=trim
    text descricao? filters=trim
    int statustransacao_id?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "srqh-_Cn_U8AacW8kq8u1LwCMWg"
}