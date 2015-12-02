
require "jwt"

payload = <<-eos
{"result": ".76","maxscore":"1","scoredetail":"{'answertext':'NO'}"}
eos

payload = JSON.load(payload)

secret = 'my$ecretK3y'

contents = {data: payload, media_type: 'application/vnd.ims.lis.v2p1.result+json'}

puts "contents: \n#{contents} encoded with #{secret}\n"

token = JWT.encode contents, secret, 'HS256'

puts "JWT ready to send: #{token}"

puts "***********decode JWT***********"

puts "***********media type = application/jwt"
decoded_token = JWT.decode token, secret, true, { :algorithm => 'HS256' }

puts "***********THIS IS INVALID MEDIA TYPE DATA...ONLY FOR TEST************"
puts "parameter headers: \n#{decoded_token[1]}"
puts "decoded_token: \n#{decoded_token[0]}"

puts "token: \n#{token}"

