// Get sacola_item record
query "sacola_item/{sacola_item_id}" verb=GET {
  api_group = "Endereços"

  input {
    int sacola_item_id? filters=min:1
  }

  stack {
    db.get sacola_item {
      field_name = "id"
      field_value = $input.sacola_item_id
    } as $sacola_item
  
    precondition ($sacola_item != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $sacola_item
  guid = "WrU-J0WmhXBCqsVEPmEkTvPr7IE"
}