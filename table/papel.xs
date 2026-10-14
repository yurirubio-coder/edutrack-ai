// Quais roles existem na API.
table papel {
  auth = false

  schema {
    int id
    text name? filters=trim
    text description? filters=trim
    timestamp created_at?
  }

  index = [{type: "primary", field: [{name: "id"}]}]
  tags = ["information"]
  guid = "05IHLgVuL0SNTun8mYSRJi288qg"
}