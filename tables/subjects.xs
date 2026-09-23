// Stores subjects with user reference, teacher and workload hours.
table subjects {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }

    // Reference to the authenticated user
    int user_id? {
      table = "user"
    }

    // Subject name
    text name filters=trim

    // Teacher or instructor name
    text? teacher filters=trim

    // Workload in hours
    int? hours
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
    {type: "btree", field: [{name: "user_id", op: "asc"}]}
  ]

  tags = ["edutrack:academics"]
}
