class ResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    tc_wire_log = Rails.application.config.tc_wire_log
    (jwt_payload, json_obj, error_msg) = JwtUtils.read_lti_service(request, TC_TP_SECRET, tc_wire_log)

    context_id = json_obj['context_id']
    user_id = json_obj['user_id']
    result_value = json_obj['result']
    result_agent_label = json_obj['result_agent_label']

    Result.create(context_id: context_id, user_id: json_obj['result_user_id'], result: result_value)

    puts "result_value: #{result_value}"

    render status: 200, nothing: true
  end
end