// Get sacola record
query "sacola/{sacola_id}" verb=GET {
  api_group = "Endereços"

  input {
    int sacola_id? filters=min:1
  }

  stack {
    db.get sacola {
      field_name = "id"
      field_value = $input.sacola_id
    } as $sacola
  
    precondition ($sacola != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $sacola
  guid = "c8-1zmceIuVH_1gF7pLFnpcYNiw"
}