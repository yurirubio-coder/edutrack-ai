table item_personalizacao {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int item_id? {
      table = "item"
    }
  
    int produto_personalizacao_id? {
      table = "produto_personalizacao"
    }
  
    int produto_personalizacao_opcao_id? {
      table = "produto_personalizacao_opcao"
    }
  
    decimal valor_adicional?
    text observacao? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "JWTb4_3wEhyH3ls8g-fHEgA2570"
}