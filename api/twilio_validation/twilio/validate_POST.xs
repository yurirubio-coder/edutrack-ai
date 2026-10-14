// This endpoint is used to validate that Twilio is working.
query "twilio/validate" verb=POST {
  api_group = "Twilio Validation"

  input {
    text to_number? filters=trim
    text body? filters=trim
  }

  stack {
    function.run twilio_send_sms {
      input = {to_number: $input.to_number, body: $input.body}
    } as $func_1
  }

  response = {status: "success"}
  guid = "aU9Q16bUMANKl7rtACtCOwjzv-U"
}