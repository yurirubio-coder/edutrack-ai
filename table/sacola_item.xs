table sacola_item {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int sacola_id? {
      table = "sacola"
    }
  
    int produto_id? {
      table = "produto"
    }
  
    int qtd?
    decimal valor_unit?
    decimal subtotal?
    text? observacao? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "CXApR8fgcNFrclVW1aAE-Ybgwcg"
}