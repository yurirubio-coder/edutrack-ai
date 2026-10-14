table produto {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text codigo? filters=trim
    text nome? filters=trim
    text descricao? filters=trim
    int qtd_disp?
    decimal preco?
    bool precisa_produzir?
    text? url_imagem? filters=trim
    bool ativo?
    int tipo_produto_id? {
      table = "tipo_produto"
    }
  
    bool vegetariano?
    bool sem_gluten?
    bool em_promocao?
    decimal? preco_promocional?
    int ordem_catalogo?
    int qtd_vendida?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "Ql4Y0-NPKaYiNfaCBwpSVKLd8Vo"
}