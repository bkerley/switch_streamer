module SwitchStreamer
  class Subscription
    JSON.mapping({id: String,
                  url: String,
                  valid: Bool,
                  created_timestamp: String})
  end
end
