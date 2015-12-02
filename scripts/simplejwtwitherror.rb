
require "jwt"

payload = {:data => 'test'}

secret = 'my$ecretK3y'

puts "payload: \n#{payload} encoded with "#{secret}"

token = JWT.encode payload, secret, 'HS256'
puts "JWT ready to send: #{token}"

# chop off a few chars
token = token[0..-3]

puts "***********decode JWT***********"

decoded_token = JWT.decode token, secret, true, { :algorithm => 'HS256' }

puts "parameter headers: \n#{decoded_token[1]}"
puts "decoded_token: \n#{decoded_token[0]}"