table endereco {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int cliente_id? {
      table = "cliente"
    }
  
    text logradouro? filters=trim
    text numero? filters=trim
    text? complemento? filters=trim
    text? referencia? filters=trim
    bool padrao?
    int cep_id? {
      table = "cep"
    }
  
    text bairro? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["information"]
  guid = "bopwUKHScsVIvVcmfo65Awll7lk"
}