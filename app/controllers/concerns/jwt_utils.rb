class JwtUtils
  JWT_SECRET = 'my$ecretK3y'

  def self.create_jwt_bearer_token(expiry_minutes, payload)
    expiry_stamp = Time.now.to_i + expiry_minutes * 60    # minutes from now
    payload['exp'] = expiry_stamp
    JwtUtils.encode_jwt payload, JWT_SECRET
  end

  def self.encode_jwt(payload, secret)
    JWT.encode payload,  secret, 'HS256'
  end

  def self.decode_jwt(jwt_payload, secret)
    begin
      decoded_token = JWT.decode jwt_payload, secret, true
      error_msg = nil
    rescue Exception => e
      error_msg = e.message
    end

    if error_msg.nil?
      payload = decoded_token[0]
      headers = decoded_token[1]
    end

    [payload, headers, error_msg]
  end

  def self.log_payload(wire_log, jwt_payload, secret)
    (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt_payload, secret)
    wire_log.log("JWT payload: #{WireLog.fold_hash(payload)}")
  end

end