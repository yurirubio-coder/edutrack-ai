table produto_personalizacao_opcao {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int produto_personalizacao_id? {
      table = "produto_personalizacao"
    }
  
    text nome? filters=trim
    text? descricao? filters=trim
    decimal ajuste_preco?
    bool ativo?
    int ordem_exibicao?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "ikUk414JFvg_yS7LxZAE6eFGUyE"
}