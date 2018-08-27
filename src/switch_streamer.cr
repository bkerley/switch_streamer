require "dotenv"
require "kemal"

require "./switch_streamer/client"
require "./switch_streamer/challenge_responder"
require "./switch_streamer/copier"
require "./switch_streamer/mastodon"
require "./switch_streamer/tweet_create_event"

# TODO: Write documentation for `SwitchStreamer`
module SwitchStreamer
  VERSION = "0.1.0"
end

Dotenv.load

client = ::SwitchStreamer::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  access_key: ENV["TWITTER_ACCESS_KEY"],
  access_secret: ENV["TWITTER_ACCESS_SECRET"],
  environment_name: ENV["TWITTER_ENVIRONMENT"],
  domain: ENV["DOMAIN"]
)

challenge_responder =
  ::SwitchStreamer::ChallengeResponder.new(ENV["TWITTER_CONSUMER_SECRET"])

mastodon =
  ::Mastodon::REST::Client.new(
      access_token: ENV["MASTODON_TARGET_ACCESS_TOKEN"],
      url: ENV["MASTODON_SERVER"])

copier =
  ::SwitchStreamer::Copier.new(mastodon: mastodon,
                               user_id: ENV["TWITTER_USER"],
                               source: ENV["TWITTER_SOURCE"]
                              )

get "/" do
  render "src/views/index.ecr"
end

post "/create_hook" do |env|
  client.create_hook

  env.redirect "/"
end

post "/destroy_hook/:id" do |env|
  hook_id = env.params.url["id"]

  client.destroy_hook hook_id

  env.redirect "/"
end

post "/create_subscription" do |env|
  client.create_subscription

  env.redirect "/"
end

post "/destroy_subscription" do |env|
  client.destroy_subscription

  env.redirect "/"
end

get "/hook/twitter" do |env|
  crc_token = env.params.query["crc_token"]
  response_token = challenge_responder.response_token(crc_token)

  env.response.content_type = "application/json"
  {response_token: response_token}.to_json
end

post "/hook/twitter" do |env|
  payload = env.params.json

  next unless payload["for_user_id"] == ENV["TWITTER_USER"]
  next if payload["tweet_create_events"].nil?

  Array(::SwitchStreamer::TweetCreateEvent).
    from_json(payload["tweet_create_events"].to_json).
    each do |event|
    copier.process event
  end
end

Kemal.run
