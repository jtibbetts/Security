class SendMessageController < ApplicationController
  skip_before_action :verify_authenticity_token

  EXPIRY_STANDARD = 5.minutes

  TOOL_PROVIDER = 'tp'

  def send_to_pseudo_outcomes_service(result_agent_label, result_agent)
    jwt_params = {"user_id" => result_agent['user_id'], "context_id" => result_agent['context_id'],
                         "resource_link_id" => result_agent['resource_link_id']}

    result_value = result_agent['results'].last
    url = "#{TOOL_CONSUMER}/tool_consumer/post_results"
    json_payload = {'result_agent_label' => result_agent_label, 'result' => result_value}
    data = json_payload.to_json

    header_addends = {'content_type' => 'application/json'}
    tp_wire_log = Rails.application.config.tp_wire_log
    response = JwtUtils.send_lti_service("outcome service", url, "post", TC_TP_SECRET, EXPIRY_STANDARD,
                                         jwt_params, data, header_addends, tp_wire_log)

    # TP records an incoming result
    eventstore_access_key = result_agent['eventstore_access_key']
    emit_event("Incoming result", WirelogUtils.tp_wire_log, eventstore_access_key, result_agent_label, 'TP', 'outcomes', 'result', result_value)

    response

  end

  def create
    json = JSON.load(request.body.read)
    authorization = env['HTTP_AUTHORIZATION']
    zones = authorization.strip.split(' ')
    jwt = zones.last

    (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt, TC_TP_SECRET)
    if error_msg.nil?
      result_agent_label = payload['result_agent_label']
      result_agent = ResultAgentAccessor.fetch_result_agent(result_agent_label)

      # if payload['agent_secret'] == result_agent['agent_secret']
        outbuf = ''
        outbuf << 'Result incoming\n'
        outbuf << JSON.pretty_generate(json)
        outbuf << ''
        rem_wire_log = Rails.application.config.rem_wire_log
        rem_wire_log.log(outbuf)

        result_str = json['results'][0]['score']
        result = result_str

        # add result to array
        result_agent['results'] << result_str

        ResultAgentAccessor.store_result_agent(result_agent_label, result_agent)

        # forward result_str back to TC via a protected REST service
        send_to_pseudo_outcomes_service(result_agent_label, result_agent)

        render text: "#{result_str} added to result set"
      # else
      #   render text: "Authentication failure: bad agent secret"
      # end
    else
      render text: error_msg
    end
  end

end