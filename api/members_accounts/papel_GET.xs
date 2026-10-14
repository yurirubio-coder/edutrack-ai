// Query all papel records
query papel verb=GET {
  api_group = "Members & Accounts"

  input {
  }

  stack {
    db.query papel {
      return = {type: "list"}
    } as $papel
  }

  response = $papel
  guid = "VBOGc1xtg4luZwTmOMTV2hU_7z4"
}