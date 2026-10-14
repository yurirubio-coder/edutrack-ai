table verification_code {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int user_id? {
      table = "user"
    }
  
    text code? filters=trim {
      sensitive = true
    }
  
    timestamp expiration?
    bool used?
    int attempts?
    text type? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["auth"]
  guid = "RYRiEtPjOx-U50Bj7DtG5hUTIpk"
}