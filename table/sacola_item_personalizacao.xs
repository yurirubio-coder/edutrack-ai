table sacola_item_personalizacao {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int sacola_item_id? {
      table = "sacola_item"
    }
  
    int produto_personalizacao_id? {
      table = "produto_personalizacao"
    }
  
    int produto_personalizacao_opcao_id? {
      table = "produto_personalizacao_opcao"
    }
  
    decimal valor_adicional?
    text? observacao? filters=trim
    int qtd?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "4rESzBV1wVvYDzlkA6PAHbTq3f8"
}