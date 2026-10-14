// Dados sobre o cliente, não de login.
table cliente {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text name? filters=trim
    text celular? filters=trim
    text cpf? filters=trim
    int status_cliente_id?
    int user_id? {
      table = "user"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
    {type: "btree|unique", field: [{name: "cpf", op: "asc"}]}
  ]

  tags = ["information"]
  guid = "_m3oB_VXUxVk25VbiqQoxBJZhok"
}