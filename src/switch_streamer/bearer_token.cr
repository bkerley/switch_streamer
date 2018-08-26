module SwitchStreamer
  class BearerToken
    JSON.mapping({token_type: String,
                  access_token: String})
  end
end
