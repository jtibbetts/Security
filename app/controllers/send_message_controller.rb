class SendMessageController < ApplicationController
  skip_before_action :verify_authenticity_token

  EXPIRY_MINUTES = 5

  TOOL_PROVIDER = 'tp'
  before_filter do |controller|
    @tp_accessor = JsonAccessor.new(TOOL_PROVIDER)
  end

  def send_to_pseudo_outcomes_service(entry)
    jwt_payload = JwtUtils.create_jwt_bearer_token(EXPIRY_MINUTES,
                                                   user_id: session[:current_user_id],
                                                   context_id: session[:current_context_id],
                                                   resource_link_id: session[:current_resource_link_id])

    json_obj = {result: entry['results'].last}
    headers = {}
    headers['content_type'] = 'application/json'
    headers["authorization: bearer #{jwt_payload}"]
    uri = "http://kinexis3000.ngrok.io/tool_consumer/post_results"
    data = json_obj.to_json

    tp_wire_log = Rails.application.config.tp_wire_log
    if tp_wire_log
      write_wirelog_header(tp_wire_log, "pseudo-outcome request",
                           "post", uri, headers, {}, data, {})
      JwtUtils.log_payload(tp_wire_log, jwt_payload, JWT_SECRET)
    end

    response = HTTParty.post(uri, body: data, headers: headers, timeout: 120)

    response

  end

  def create
    json = JSON.load(request.body.read)

    outbuf = ''
    outbuf << '<h1>Echo result</h1><pre>'
    outbuf << JSON.pretty_generate(json)
    outbuf << '</pre>'

    rem_wire_log = Rails.application.config.rem_wire_log
    rem_wire_log.log(outbuf)

    result_str = json['results'][0]['score']
    result = result_str

    authorization = env['HTTP_AUTHORIZATION']
    zones = authorization.strip.split(' ')
    jwt_payload = zones.last

    (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt_payload, JWT_SECRET)
    if error_msg.nil?
      metasession_id = payload['metasession_id']
      entry = @tp_accessor.fetch_entry(metasession_id)

      # add result to array
      entry['results'] << result_str

      @tp_accessor.store_entry(metasession_id, entry)

      # forward result_str back to TC via a protected REST service
      send_to_pseudo_outcomes_service(entry)

      render text: "#{result_str} added to result set"
    else
      render text: error_msg
    end
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