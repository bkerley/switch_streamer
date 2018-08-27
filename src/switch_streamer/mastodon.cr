require "mastodon"

module SwitchStreamer
  class Mastodon
    def initialize(access_token, server)
      @client = ::Mastodon::REST::Client.new(
        url: server,
        access_token: access_token)
    end

    def create_status(status,
                      media_ids)
      @client.create_status(status: status, media_ids: media_ids)
    end


  end
end
