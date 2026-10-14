// API para listar produtos em promoções
query "promocoes/produtos" verb=GET {
  api_group = "Gestão"
  auth = "user"

  input {
  }

  stack {
    db.query produto {
      where = $db.produto.em_promocao == true
      sort = {ordem_catalogo: "asc", id: "asc"}
      return = {type: "list"}
    } as $produtos
  }

  response = $produtos
  guid = "zOKhURR1PKl0l73llVpZOI_KsR0"
}