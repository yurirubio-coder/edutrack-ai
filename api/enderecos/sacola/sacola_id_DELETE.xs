// Delete sacola record.
query "sacola/{sacola_id}" verb=DELETE {
  api_group = "Endereços"

  input {
    int sacola_id? filters=min:1
  }

  stack {
    db.del sacola {
      field_name = "id"
      field_value = $input.sacola_id
    }
  }

  response = null
  guid = "V9urZ3DOvSB6I79rPhd3namBYRs"
}