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

  def emit_event(eventstore_access_jwt, metasession_id, event_source, event_type, event_name, event_value)
    jwt_params = {'metasession_id' => metasession_id}
    json_payload = {'event_source' => event_source, 'event_type' => event_type,
              'event_name' => event_name, 'event_value' => event_value}
    data = json_payload.to_json
    url = "#{EVENT_STORE}/eventstore/post_event"

    headers = {}
    headers['content_type'] = 'application/json'
    headers["authorization"] =  "bearer #{eventstore_access_jwt}"

    response = HTTParty.post(url, body: data, headers: headers, timeout: 120)

    tp_wire_log = Rails.application.config.tp_wire_log
    if tp_wire_log
      write_wirelog_header(tp_wire_log, "pseudo-outcome request",
                           "post", url, headers, {}, data, {})
    end

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
