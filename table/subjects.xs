// Guarda as disciplinas cadastradas pelo aluno.
table subjects {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }

    // Subject name
    text name filters=trim

    // Subject description
    text? description? filters=trim

    // Subject code
    text? code? filters=trim

    int user_id? {
      table = "user"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
    {type: "btree", field: [{name: "user_id", op: "asc"}]}
  ]
  guid = "vMgjmcR-Gntf8aHvwMzSC4HfsBc"
}

