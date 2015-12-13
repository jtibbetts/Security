class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  skip_before_action :verify_authenticity_token

  TOOL_CONSUMER = "http://kinexis3000.ngrok.io"
  TOOL_PROVIDER = "http://kinexis3001.ngrok.io"
  EVENT_STORE   = "http://kinexis3002.ngrok.io"

  # if no internet + add these to /etc/hosts
  # TOOL_CONSUMER = "http://localhost:3000"
  # TOOL_PROVIDER = "http://localhost:3001"
  # EVENT_STORE   = "http://localhost:3001"

  TC_TP_SECRET = 'my$ecretK3y'
  TC_ES_SECRET = 'myEvent$toreK3y'

  def get_eventstore_access_jwt(correlation_id)
    jwt_params = {'correlation_id' => correlation_id}

    url = "#{TOOL_CONSUMER}/tool_consumer/eventstore_access_jwt"

    header_addends = {'accept' => 'application/json'}

    response = JwtUtils.send_lti_service("Get Eventstore Access JWT", url, "get", TC_TP_SECRET,
                                         5, jwt_params, nil, header_addends,
                                         WirelogUtils.tp_wire_log, WirelogUtils.tc_wire_log)

    json_obj = JSON.load(response.body)
    if response.code == 200
      result = json_obj['jwt']
    else
      raise "Error getting eventstore_access_jwt: #{error_msg}"
    end
    result
  end

  def emit_event(title, src_wirelog, eventstore_access_jwt, metasession_id, event_source,
                 event_type, event_name, event_value)
    jwt_params = {'metasession_id' => metasession_id}
    json_payload = {'eventstore_access_jwt' => eventstore_access_jwt, 'event_source' => event_source,
                    'event_type' => event_type, 'event_name' => event_name, 'event_value' => event_value}

    data = json_payload.to_json
    url = "#{EVENT_STORE}/events/post_event"

    header_addends = {'content_type' => 'application/json'}

    response = JwtUtils.send_lti_service(title, url, "post", TC_ES_SECRET,
                     5, jwt_params, data, header_addends,
                     src_wirelog, WirelogUtils.rem_wire_log)

    response

  end

  private

  def write_wirelog_header(wire_log, title, method, uri, headers = {},
                           parameters = {}, body = nil, output_parameters = {})
    wire_log.timestamp
    wire_log.raw_log((title.nil?) ? 'LtiService' : "LtiService: #{title}")
    wire_log.raw_log("#{method.upcase} #{uri}")
    unless headers.blank?
      wire_log.raw_log('Headers:')
      headers.each { |k, v| wire_log.raw_log("#{k}: #{v}") }
    end
    parameters.each { |k, v| output_parameters[k] = v unless k =~ /^oauth_/ }

    if output_parameters.length > 0
      wire_log.raw_log('Parameters:')
      output_parameters.each { |k, v| wire_log.raw_log("#{k}: #{v}") }
    end
    if body
      wire_log.raw_log('Body:')
      wire_log.raw_log(body)
    end
    wire_log.newline
    wire_log.flush
  end

end
