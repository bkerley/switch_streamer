require "openssl/hmac"
require "base64"

require "./client"

module SwitchStreamer
  class HookValidator
    property consumer_secret : String

    def initialize(consumer_secret : String)
      @consumer_secret = consumer_secret
    end

    def validate_payload(expected_signature : String, payload : IO?)
      return if payload.nil?
      data = payload.gets_to_end
      
      pp expected_signature
      
      digest = OpenSSL::HMAC.digest(:sha256,
                                    @consumer_secret,
                                    data)

      encoded_digest = "sha256=" + Base64.strict_encode digest

      pp encoded_digest
      
      return nil unless expected_signature == encoded_digest

      return data
    end
  end
end
