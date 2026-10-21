// Delete subjects record for authenticated user
query "subjects/{subjects_id}" verb=DELETE {
  api_group = "College"
  auth = "user"

  input {
    int subjects_id filters=min:1
  }

  stack {
    db.get subjects {
      field_name = "id"
      field_value = $input.subjects_id
    } as $subject

    precondition ($subject != null && $subject.user_id == $auth.id) {
      error_type = "notfound"
      error = "Subject not found."
    }

    db.del subjects {
      field_name = "id"
      field_value = $input.subjects_id
    }
  }

  response = null
  guid = "hyBV55jszGT3h6neTo_aPi1_kzE"
}

