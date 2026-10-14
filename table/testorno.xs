table testorno {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text numero? filters=trim
    decimal valor?
    int solcancelamento_id? {
      table = "solcancelamento"
    }
  
    int status_testorno_id? {
      table = "status_testorno"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  guid = "hIQVm-vHdoalrWRt6Mra_BuA36A"
}