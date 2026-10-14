// Guarda as obrigações acadêmicas do aluno (lições, provas, trabalhos) vinculadas a cada disciplina.
table academic_tasks {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }

    text title filters=trim {
      description = "Task title"
    }
    text? description? filters=trim {
      description = "Task description"
    }
    date? due_date? {
      description = "Due date"
    }
    text status?="pending" {
      description = "Status"
    }
    int subject_id? {
      table = "subjects"
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
}

