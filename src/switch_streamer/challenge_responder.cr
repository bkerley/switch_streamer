require "openssl/hmac"
require "base64"

require "./client"

module SwitchStreamer
  class ChallengeResponder
    property consumer_secret : String

    def initialize(consumer_secret : String)
      @consumer_secret = consumer_secret
    end

    def response_token(crc_token : String)
      digest = OpenSSL::HMAC.digest(:sha256,
                                    @consumer_secret,
                                    crc_token)

      encoded_digest = Base64.strict_encode digest

      return "sha256=#{encoded_digest}"
    end
  end
end
