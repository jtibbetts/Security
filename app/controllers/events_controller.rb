class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    tc_wire_log = Rails.application.config.tc_wire_log
    (json_obj, jwt_payload, error_msg) = JwtUtils.read_lti_service(request, TC_TP_SECRET, tc_wire_log)

    event_source = json_obj['event_source']
    event_type = json_obj['event_type']
    event_name = json_obj['event_name']
    result_value = json_obj['event_value']

    if error_msg.present?
      result_value = error_msg
    end

    Event.create(event_source: event_source, event_type: event_type, event_name: event_name, event_value: result_value)

    render status: 200, nothing: true
  end

  def lti_launch
    if request.post?
      jwt_payload = params[:jwt_payload]
      tool = params[:tool]

      (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt_payload, secret)
      if error_msg.present?
        raise "Authentication failure: #{error_msg}"
      end

      render 'eventstore/eventstore'
    end
  end

end