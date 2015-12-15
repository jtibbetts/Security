class JwtUtils
  TC_TP_SECRET = 'my$ecretK3y'

  require 'base64'

  # primitives
  def self.create_jwt(secret, expiry_seconds, payload)
    if expiry_seconds > 0
      expiry_stamp = Time.now.to_i + expiry_seconds
    end
    payload['exp'] = expiry_stamp
    JwtUtils.encode_jwt payload, secret
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
    if error_msg.present?
      raise error_msg
    end
    wire_log.log("JWT payload: #{WireLog.fold_hash(payload)}")
  end


  # LTI launch
  def self.lti_launch_body(launch_url, launch_payload, secret, wire_log, title, is_open_in_external_window=false)
    attribute_for_external_window = is_open_in_external_window ? 'target="_blank"' : ''

    body = ''
    # for endpoint verification
    jwt_payload = JwtUtils.encode_jwt(launch_payload, secret)

    body +=       %Q(
<div id="ltiLaunchFormSubmitArea">
  <form action="#{launch_url}" #{attribute_for_external_window}
    name="ltiLaunchForm" id="ltiLaunchForm" method="post"
    encType="application/x-www-form-urlencoded">
)

    body += %Q(      <input type="hidden" name="jwt_payload" value="#{CGI.escapeHTML(jwt_payload)}"/>\n)

    body += %Q{  </form>
</div>
<script language="javascript">
  document.ltiLaunchForm.submit();
</script>
      }

    tc_wire_log = Rails.application.config.tc_wire_log

    if tc_wire_log
      tc_wire_log.timestamp
      tc_wire_log.raw_log((title.nil?) ? 'LtiMessage' : "LtiMessage: #{title}")
      tc_wire_log.raw_log "LaunchUrl: #{launch_url}"
      tc_wire_log.raw_log body.strip
      tc_wire_log.flush
    end

    log_payload(tc_wire_log, jwt_payload, secret)

    body
  end

  # LTI services
  def self.send_lti_service(title, url, method, secret, jwt,
      body_data="", header_addends={},
      src_wirelog=nil, trg_wirelog=nil)
    headers = header_addends.clone
    headers['authorization'] = "bearer #{jwt}"

    if src_wirelog
      WirelogUtils.write_wirelog_header(src_wirelog, title,
                           "post", url, headers, {}, body_data, {})
      JwtUtils.log_payload(src_wirelog, jwt, secret)
    end

    case method
      when 'get'
        response = HTTParty.get(url, headers: headers, timeout: 120)
      when 'post'
        response = HTTParty.post(url, body: body_data, headers: headers, timeout: 120)
      when 'put'
        response = HTTParty.put(url, body: body_data, headers: headers, timeout: 120)
      when 'delete'
        response = HTTParty.delete(url, headers: headers, timeout: 120)
    end

    WirelogUtils.log_response(trg_wirelog, response, title) if trg_wirelog

    response
  end

  def self.read_lti_service(request, secret, wirelog)
    jwt = request.authorization.split(' ').last

    json_str = request.body.read
    json_obj = JSON.load(json_str)

    (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt, secret)

    if error_msg.present?
      msg = "VerificationError on Post Result: #{error_msg}"
      [nil, nil, error_msg]
      return
    end

    [payload, json_obj, error_msg]
  end

end