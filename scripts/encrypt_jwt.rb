# Full

require "jwt"

JWT_SECRET = 'mysecret'
jwt = JWT.encode({"mydata" => "Where the hand of man has never set foot"},  JWT_SECRET, 'HS256')
puts "JWT: #{jwt}"

# Cipher initialize
cipher = OpenSSL::Cipher.new('AES-256-CBC')
x = cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv

# whenever we cipher
encrypted = cipher.update(jwt) + cipher.final
puts %Q(Encrypted value: "#{encrypted.unpack('H*')}")

# assume partner has key and iv

# Decipher initialize
decipher = OpenSSL::Cipher.new('AES-256-CBC')
decipher.decrypt
decipher.key = key
decipher.iv = iv

# whenever we decipher
jwt = decipher.update(encrypted) + decipher.final

decoded_tokens = JWT.decode(jwt, JWT_SECRET)
puts "Decoded JWT: #{decoded_tokens.inspect}"

