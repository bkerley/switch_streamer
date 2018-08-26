require "twitter-crystal"
require "http/client"

require "./bearer_token"
require "./subscription"

module SwitchStreamer
  class Client
    property bearer_token : String
    property sub_client : ::HTTP::Client
    property environment_name : String

    def initialize(consumer_key : String, consumer_secret : String,
                   access_key : String, access_secret : String,
                   environment_name : String)
      @tw_client = ::Twitter::REST::Client.new(
        consumer_key, consumer_secret,
        access_key, access_secret)

      @environment_name = environment_name

      bt_client = ::HTTP::Client.new("api.twitter.com", tls: true)

      bt_client.basic_auth(consumer_key, consumer_secret)
      resp = bt_client.post("/oauth2/token",
                             form: {"grant_type" => "client_credentials"})

      bt = BearerToken.from_json resp.body

      raise "no bearer token" unless bt.is_a? BearerToken

      @bearer_token = bt.access_token

      @sub_client = ::HTTP::Client.new("api.twitter.com", tls: true)

      @sub_client.before_request do |req|
        req.headers["Authorization"] = "Bearer #{@bearer_token}"
      end
    end

    def list_subscriptions
      endpoint = "/1.1/account_activity/all/#{@environment_name}/webhooks.json"
      resp = @sub_client.get(endpoint)
p resp.body
      Array(Subscription).from_json(resp.body)
    end
  end
end
