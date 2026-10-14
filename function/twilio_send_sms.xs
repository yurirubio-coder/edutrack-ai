// Send an SMS with Twilio
function twilio_send_sms {
  input {
    // The phone number to send the SMS to
    text to_number filters=min:1
  
    // The SMS body to send
    text body filters=min:1
  }

  stack {
    precondition ($env.workspace.twilio_account_sid != "") {
      error = 'Please set your "twilio_account_sid" environment variable.'
    }
  
    precondition ($env.workspace.twilio_from_number != "") {
      error = 'Please set your "twilio_from_number" environment variable.'
    }
  
    precondition ($env.workspace.twilio_auth_token != "") {
      error = 'Please set your "twilio_auth_token" environment variable.'
    }
  
    // Sends an SMS to a phone number through Twilio
    api.request {
      url = "https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json"
        |sprintf:$env.workspace.twilio_account_sid
      method = "POST"
      params = {}
        |set:"To":($input.to_number
          |replace:('["-", "+"," ","\t","(",")"]'|json_decode):""
        )
        |set:"From":$env.workspace.twilio_from_number
        |set:"Body":$input.body
      headers = []
        |push:"Content-Type: multipart/form-data"
        |push:("Authorization: Basic %s"
          |sprintf:("%s:%s"
            |sprintf:$env.workspace.twilio_account_sid:$env.workspace.twilio_auth_token
            |base64_encode
          )
        )
    } as $api_response
  
    precondition ($api_response.response.status == 201) {
      error = $api_response.response.result.message
    }
  }

  response = null
  guid = "5aeY9IElfsPrGJKSQl1ChR5jzDU."
}