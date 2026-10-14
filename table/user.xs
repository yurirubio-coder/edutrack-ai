// Guarda informações sobre o login do usuário.
table user {
  auth = true

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text name filters=trim
    email? email filters=trim|lower
    password? password filters=min:8|minAlpha:1|minDigit:1 {
      visibility = "internal"
    }
  
    object password_reset? {
      schema {
        text token? {
          visibility = "internal"
        }
      
        timestamp? expiration? {
          visibility = "internal"
        }
      
        bool used? {
          visibility = "internal"
        }
      }
    }
  
    int papel_id? {
      table = "papel"
    }
  
    int login_attempts?
    timestamp? login_blocked_until?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {
      type : "btree"
      field: [{name: "created_at", op: "desc"}, {name: "email", op: "asc"}]
    }
    {type: "btree|unique", field: [{name: "email", op: "asc"}]}
  ]

  tags = ["xano:quick-start", "auth"]
  guid = "g8tpjso2orFaPgdxKGzuuR66M1k"
}