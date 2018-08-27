module SwitchStreamer
  struct Entities
    JSON.mapping({
                   hashtags: Array(Hashtag),
                   media: Array(Media)?,
                          urls: Array(Url),
                   user_mentions: Array(UserMention),
                   symbols: Array(Symbol),
                   polls: Array(Poll)?
                 })
  end

  struct ExtendedEntities
    JSON.mapping({
                   media: Array(Media)?
                 })
  end

  abstract struct Tag
             JSON.mapping({
                            text: String,
                            indices: Array(Int16)
                          })
           end

  struct Hashtag < Tag
  end

  struct Media
    JSON.mapping({
                   display_url: String,
                   expanded_url: String,
                   id: UInt64,
                   id_str: String,
                   indices: Array(Int16),
                   media_url: String,
                   media_url_https: String,
                   sizes: Media::Sizes,
                   source_status_id: UInt64?,
                   source_status_id_str: String?,
                   source_user_id: UInt64?, # Not in docs
                   source_user_id_str: String?, # Not in docs
                   type: String,
                   url: String,
                   video_info: Media::VideoInfo?
                 })
  end

  struct Media::VideoInfo
    JSON.mapping({
                   aspect_ratio: Array(UInt8),
                   duration_millis: UInt32,
                   variants: Array(Media::VideoVariant)
                 })
  end

  struct Media::VideoVariant
    JSON.mapping({
                   bitrate: UInt32?,
                   content_type: String,
                   url: String
                 })
  end

  struct Media::Sizes
    JSON.mapping({
                   thumb: Media::Size,
                   large: Media::Size,
                   medium: Media::Size,
                   small: Media::Size
                 })
  end

  struct Media::Size
    JSON.mapping({
                   h: Int32,
                   w: Int32,
                   resize: String
                 })
  end

  # TODO: Expanded and/or Enhanced URL enrichments
  # https://developer.twitter.com/en/docs/tweets/data-dictionary/overview/entities-object1#urls
  struct Url
    JSON.mapping({
                   display_url: String,
                   expanded_url: String,
                   indices: Array(Int16),
                   url: String
                 })
  end

  struct User
    JSON.mapping({
                   id_str: String
                 })
  end

  struct UserMention
    JSON.mapping({
                   id: UInt64,
                   id_str: String,
                   screen_name: String,
                   name: String,
                   indices: Array(Int16)
                 })
  end

  struct Symbol < Tag
  end

  struct Poll
    JSON.mapping({
                   options: Array(Poll::Option),
                   end_datetime: String,
                   duration_minutes: String
                 })
  end

  struct Poll::Option
    JSON.mapping({
                   position: Int16,
                   text: String
                 })
  end
end
