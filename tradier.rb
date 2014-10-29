require 'uri'
require 'net/https'
require 'json'

underlying = 'vxx'
high_pct = 0.15
low_pct = 0.05

while true do
  # request: quote
  uri = URI.parse("https://sandbox.tradier.com/v1/markets/quotes?symbols=#{underlying}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 30
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  request = Net::HTTP::Get.new(uri.request_uri)
  # Headers
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer " + ENV["TOKEN"]
  # Send synchronously
  underlying_price = http.request(request)
  underlying_price = JSON.parse(underlying_price.body)["quotes"]["quote"]["last"]

  # request: options chain
  uri = URI.parse("https://sandbox.tradier.com/v1/markets/options/chains?symbol=#{underlying}&expiration=2014-11-7")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 30
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  request = Net::HTTP::Get.new(uri.request_uri)
  # Headers
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer " + ENV["TOKEN"]
  # Send synchronously
  response = http.request(request)
  readable = JSON.parse(response.body)
  readable = readable["options"]["option"]

  put_lower_bound = underlying_price * (1 - high_pct)
  put_upper_bound = underlying_price * (1 - low_pct)
  call_lower_bound = underlying_price * (1 + low_pct)
  call_upper_bound = underlying_price * (1 + high_pct)

  filtered = readable.select { |hash| (hash["strike"] >= put_lower_bound && hash["strike"] <= put_upper_bound && hash["option_type"] == "put") || (hash["strike"] >= call_lower_bound && hash["strike"] <= call_upper_bound && hash["option_type"] == "call")}

  puts underlying_price
  filtered.each do |option|
    option["midpoint"] = (option["bid"] + option["ask"]) / 2
    option["timestamp"] = Time.now
    puts option["description"] + " | " + "bid / ask: " + option["bid"].to_s + " / " + option["ask"].to_s + " | " + option["midpoint"].to_s
  end
end
