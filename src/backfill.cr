require "dotenv"

require "./switch_streamer/client"
require "./switch_streamer/challenge_responder"
require "./switch_streamer/copier"
require "./switch_streamer/hook_validator"
require "./switch_streamer/mastodon"
require "./switch_streamer/tweet_create_event"

Dotenv.load

client = ::SwitchStreamer::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  access_key: ENV["TWITTER_ACCESS_KEY"],
  access_secret: ENV["TWITTER_ACCESS_SECRET"],
  environment_name: ENV["TWITTER_ENVIRONMENT"],
  domain: "x"
)

challenge_responder =
  ::SwitchStreamer::ChallengeResponder.new(ENV["TWITTER_CONSUMER_SECRET"])

hook_validator =
  ::SwitchStreamer::HookValidator.new(ENV["TWITTER_CONSUMER_SECRET"])

mastodon =
  ::Mastodon::REST::Client.new(
      access_token: ENV["MASTODON_TARGET_ACCESS_TOKEN"],
      url: ENV["MASTODON_SERVER"])

copier =
  ::SwitchStreamer::Copier.new(mastodon: mastodon,
                               user_id: ENV["TWITTER_USER"],
                               source: ENV["TWITTER_SOURCE"]
                              )

ids = ARGV

matcher = %r{^https://twitter.com/.+/status/(\d+)}

ids.each do |id|
  if md = matcher.match id
    id = md[1]
  end

  p id

  tweet = client.get_tweet(id)

  copier.process(tweet)
end

# post "/hook/twitter" do |env|
#   expected_signature = env.request.headers["x-twitter-webhooks-signature"]
#   valid = hook_validator.validate_payload(expected_signature,
#                                           env.request.body)

#   next unless valid

#   payload = JSON.parse(valid).raw
#   next unless payload.is_a? Hash
#   next unless payload["for_user_id"] == ENV["TWITTER_USER"]
#   next if payload["tweet_create_events"].nil?


#   Array(::SwitchStreamer::TweetCreateEvent).
#     from_json(payload["tweet_create_events"].to_json).
#     each do |event|
#     spawn do
#       copier.process event
#     end
#   end
# end
