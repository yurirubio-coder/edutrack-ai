table item {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int pedido_id? {
      table = "pedido"
    }
  
    int nro?
    int qtd?
    decimal valor_unit?
    decimal subtotal?
    int produto_id? {
      table = "produto"
    }
  
    int status_item_id? {
      table = "status_item"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "bM6QNbEC2o1-HJhqj7uq0Cj1zgc"
}