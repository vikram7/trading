require 'uri'
require 'net/https'
require 'json'

# Request: Market Quotes (https://sandbox.tradier.com/v1/markets/quotes?symbols=spy)
underlying = 'vxx'
uri = URI.parse("https://sandbox.tradier.com/v1/markets/options/chains?symbol=#{underlying}&expiration=2014-11-14")
http = Net::HTTP.new(uri.host, uri.port)
http.read_timeout = 30
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER
request = Net::HTTP::Get.new(uri.request_uri)

# Headers
request["Accept"] = "application/json"
request["Authorization"] = "Bearer <API KEY>"

# Send synchronously
response = http.request(request)
readable = JSON.parse(response.body)
readable = readable["options"]["option"]
