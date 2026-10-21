// Guarda as obrigações acadêmicas do aluno (lições, provas, trabalhos) vinculadas a cada disciplina.
table academic_tasks {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // Task title
    text title filters=trim
  
    // Task description
    text? description? filters=trim
  
    // Due date
    date? due_date?
  
    // Status
    text status?=pending
  
    int subject_id? {
      table = ""
    }
  
    int user_id? {
      table = "user"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
    {type: "btree", field: [{name: "user_id", op: "asc"}]}
  ]

  guid = "BVwE7XOzSrb-7LUEx-FKPMY17o0"
}