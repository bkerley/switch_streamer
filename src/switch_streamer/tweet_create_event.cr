require "./entities"

module SwitchStreamer
  struct TweetCreateEvent
    JSON.mapping({created_at: String,
                  id: Int64,
                  id_str: String,
                  text: String,
                  full_text: String?,
                  truncated: Bool,
                  source: String,
                  entities: Entities?,
                  extended_entities: ExtendedEntities?,
                  user: User
                 })
  end
end
