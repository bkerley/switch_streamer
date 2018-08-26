require "dotenv"
require "kemal"

require "./switch_streamer/client"

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
  environment_name: ENV["TWITTER_ENVIRONMENT"]
)

get "/" do
  render "src/views/index.ecr"
end


Kemal.run
