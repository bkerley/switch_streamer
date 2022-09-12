require "http/client"
require "uuid"

module SwitchStreamer
  class Copier
    COPY_BUF_SIZE = 1024 * 1024
    VIDEO_UPLOAD_LIMIT = 64 * 1024 * 1024

    @user_id : String
    @source : String

    def initialize(user_id, source)
      @user_id = user_id
      @source = source
    end

    def process(tweet)
      return unless tweet.user.id_str == @user_id
      pp tweet.source
      pp @source
      pp tweet.source == @source
      return unless tweet.source == @source

      unless (unfiltered_text = tweet.full_text).is_a?(String)
        unfiltered_text = tweet.text
      end

      text = unfiltered_text.gsub(%r{https://t.co.+$},"").strip

      mastodon = ::Mastodon::REST::Client.new(
        access_token: ENV["MASTODON_TARGET_ACCESS_TOKEN"],
        url: ENV["MASTODON_SERVER"])

      attachments = process_media(mastodon, tweet)

      mastodon.
        create_status(status: text,
                      media_ids: attachments.map(&.id))
    end

    private def process_media(mastodon, tweet)
      blank = [] of ::Mastodon::Entities::Attachment
      extended_entities = tweet.extended_entities
      return blank if extended_entities.nil?
      media = extended_entities.media
      return blank if media.nil?

      media.map do |medium|
        pp medium
        case medium.type
        when "video"
          process_video(mastodon, medium)
        when "photo"
          process_photo(mastodon, medium)
        else
          nil
        end
      end.compact
    end

    private def process_photo(mastodon, photo)
      url = photo.media_url_https + ":large"

      pp url

      upload(mastodon, url)
    end

    private def process_video(mastodon, video)
      video_info = video.video_info
      return nil if video_info.nil?

      seconds = (video_info.duration_millis / 1000) + 1

      best_variant = video_info.variants.reduce do |best, current|
        bst_br = best.bitrate
        next current if bst_br.nil?
        cur_br = current.bitrate
        next best if cur_br.nil?

        next best if (cur_br * seconds) > VIDEO_UPLOAD_LIMIT

        next current if cur_br > bst_br

        best
      end

      upload(mastodon, best_variant.url)
    end

    private def upload(mastodon, url)
      filename = UUID.random.to_s

      media_attachment = nil

      File.tempfile(filename) do |temp|
        HTTP::Client.get url do |resp|

          status = resp.status_code
          unless (status >= 200) && (status <= 299)
            temp.close
            temp.delete
            return nil
          end

          buf = Bytes.new COPY_BUF_SIZE

          reader = resp.body_io

          while 0 != (got = reader.read(buf))
            temp.write buf[0, got]
          end

          temp.flush
        end

        p temp.path
        media_attachment = mastodon.media_upload temp.path

        temp.close
        temp.delete

      end

      return media_attachment
    end
  end
end
