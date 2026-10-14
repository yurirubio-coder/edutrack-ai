// API para listar as categorias dinamicamente.
query "tipos-produto" verb=GET {
  api_group = "Catalog"

  input {
  }

  stack {
    db.query tipo_produto {
      sort = {id: "asc"}
      return = {type: "list"}
    } as $tipos_produto
  }

  response = $tipos_produto
  guid = "T_0zOGC85yRNgy6FNjKIHUADufk"
}