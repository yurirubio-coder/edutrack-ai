table produto_personalizacao {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int produto_id? {
      table = "produto"
    }
  
    text nome? filters=trim
    text? descricao? filters=trim
    bool obrigatoria?
    bool multipla_escolha?
    int ordem_exibicao?
    int produto_personalizacao_tipo_controle_id? {
      table = "produto_personalizacao_tipo_controle"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "DjeDCwtEdYSJDq91QFgvfsMnPuo"
}