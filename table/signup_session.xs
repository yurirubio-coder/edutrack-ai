table signup_session {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text token? filters=trim
    email email? filters=trim|lower
    bool email_verified?
    text celular? filters=trim
    bool phone_verified?
    password password? {
      sensitive = true
      visibility = "internal"
    }
  
    text name? filters=trim
    timestamp? expiration?
    text email_code? filters=trim
    text phone_code? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["auth"]
  guid = "HdBddzrFXtWj5I9iIUedv9JZxNM"
}