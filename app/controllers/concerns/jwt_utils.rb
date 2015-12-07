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

  def self.lti_launch_body(launch_url, launch_payload, secret, wire_log, title)
    payload = launch_payload.clone

    body = ''

    payload[:normalized_url] = self.normalize_url(launch_url)
    jwt_payload = JwtUtils.encode_jwt(launch_payload, secret)

    body +=       %Q(
<div id="ltiLaunchFormSubmitArea">
  <form action="#{launch_url}"
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

  private

  def self.normalize_url(url)
    u = URI.parse(url)
    "#{u.scheme.downcase}://#{u.host.downcase}#{(u.scheme.downcase == 'http' && u.port != 80) || (u.scheme.downcase == 'https' && u.port != 443) ? ":#{u.port}" : ""}#{(u.path && u.path != '') ? u.path : '/'}"
  end

end