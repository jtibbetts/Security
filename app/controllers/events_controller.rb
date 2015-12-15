class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    rem_wire_log = WirelogUtils.rem_wire_log
    (jwt_payload, json_obj, error_msg) = JwtUtils.read_lti_service(request, TC_ES_SECRET, rem_wire_log)

    event_source = json_obj['event_source']
    event_type = json_obj['event_type']
    event_name = json_obj['event_name']
    event_value = json_obj['event_value']

    if error_msg.present?
      result_value = error_msg
    end

    Event.create(event_source: event_source, event_type: event_type, event_name: event_name, event_value: event_value)

    render status: 200, nothing: true
  end

  def lti_launch
    if request.post?
      jwt_payload = params[:jwt_payload]
      tool = params[:tool]

      (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt_payload, TC_ES_SECRET)
      if error_msg.present?
        raise "Authentication failure: #{error_msg}"
      end

      @events = Event.all

      render 'index'
    end
  end

end