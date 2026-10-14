query "menu/produtos" verb=GET {
  api_group = "Gestão"
  auth = "user"

  input {
  }

  stack {
    db.query produto {
      sort = {ordem_catalogo: "asc", id: "asc"}
      return = {type: "list"}
    } as $produtos
  
    foreach ($produtos) {
      each as $produto_item {
        db.get tipo_produto {
          field_name = "id"
          field_value = $produto_item.tipo_produto_id
        } as $tipo_produto
      
        var.update $produto_item {
          value = $produto_item|set:"tipo_produto":$tipo_produto
        }
      }
    }
  }

  response = $produtos
  guid = "dcvijym75OEq9VQZFoSXTkTFZy0"
}