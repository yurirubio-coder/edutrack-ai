// Query subjects records for authenticated user
query subjects verb=GET {
  api_group = "College"
  auth = "user"

  input {
  }

  stack {
    db.query subjects {
      where = $db.subjects.user_id == $auth.id
      return = {type: "list"}
    } as $subjects
  }

  response = $subjects
  guid = "-QX86L29ps0mw627KBPvdCq_0Q0"
}

