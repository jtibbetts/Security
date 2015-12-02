class PostResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    json_str = request.body.read
    json_obj = JSON.load(json_str)
    result_value = json_obj['result']
    puts "result_value: #{result_value}"

    tc_wire_log = Rails.application.config.tc_wire_log
    tc_wire_log.log_response(response, "pseudo-outcome response") if tc_wire_log

    render status: 200, nothing: true
  end
end