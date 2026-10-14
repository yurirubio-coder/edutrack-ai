// Tabela para testes.
table posts {
  auth = false

  schema {
    int id
    timestamp createdAt?=now {
      visibility = "private"
    }
  
    text body? filters=trim
    int user_id? {
      table = "user"
    }
  }

  index = [{type: "primary", field: [{name: "id"}]}]
  tags = ["test"]
  guid = "dwfkt66Jxvom7-GTKd12boh2htc"
}