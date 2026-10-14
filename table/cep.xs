table cep {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text cep? filters=trim
    text cidade? filters=trim
    text estado? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["information"]
  guid = "usokM8sTC7K-uk910qb-j1S-zz8"
}