# switch_streamer

copies tweets from nintendo switch to mastodon using twitter webhooks

works on heroku!

## Usage

1. copy `.env.example` to `.env`
2. edit the values for your twitter api key that you have to literally beg
   and grovel for now
3. edit the values for your mastodon server and tokens; getting the access token
   can be done with
   [https://mastodon-oauth-utility.herokuapp.com][https://mastodon-oauth-utility.herokuapp.com]
4. push it to heroku
5. test it

## Development

no tests, ngrok can be useful for local development (twitter needs to GET and
POST)

## Contributing

1. Fork it (<https://github.com/bkerley/switch_streamer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [bkerley](https://github.com/bkerley) Bryce Kerley - creator, maintainer
