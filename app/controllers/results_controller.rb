class ResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    tc_wire_log = Rails.application.config.tc_wire_log
    (json_obj, jwt_payload, error_msg) = JwtUtils.read_lti_service(request, TC_TP_SECRET, tc_wire_log)

    result_value = json_obj['result']
    result_agent_label = json_obj['result_agent_label']

    Result.create(context_id: jwt_payload['context_id'], user_id: jwt_payload['user_id'], result: result_value)

    puts "result_value: #{result_value}"

    render status: 200, nothing: true
  end
end