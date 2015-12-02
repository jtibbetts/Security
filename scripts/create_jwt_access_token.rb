
require "jwt"

payload = <<-eos
{"metasession": "12345432345623434234234","return_url":"https://foo.example.org/result_listener"}
eos

payload = JSON.load(payload)

secret = 'my$ecretK3y'

exp = Time.now.to_i + 60 * 3600  # 60 minute grace period

contents = {data: payload, exp: exp}

puts "contents: \n#{contents} encoded with #{secret}\n"

token = JWT.encode contents, secret, 'HS256'

puts "JWT ready to send: #{token}"

puts "***********decode JWT***********"

puts "***********media type = application/jwt"
decoded_token = JWT.decode token, secret, true, { :algorithm => 'HS256' }

puts "***********Use this token to pass to Dependent Party************"

puts "parameter headers: \n#{decoded_token[1]}"
puts "decoded_token: \n#{decoded_token[0]}"

puts "token: \n#{token}"

