class ToolConsumerController < ApplicationController

  def clear_log
    style_heading = <<STYLE
<head>
<style>
.ToolConsumer {
}
.ToolProvider {
	margin-left: 25%;
}
.Remote {
  margin-left: 50%;
}
.RemoteResponse {
  margin-left: 25%;
}
.ToolProviderResponse {
	margin-left: 25%;
}
.ToolConsumerResponse {
}
</style>
</head>

STYLE

    full_filename = File.expand_path('public/wirelog.html')
    f = File.open(full_filename, 'w')
    f.truncate(0)
    f.write(style_heading)
    f.close

    Result.delete_all
    Event.delete_all
    ResultAgent.delete_all
    redirect_to '/tool_consumer'
  end

  # from launch action POST message
  def create
    launch_payload = session[:payload]

    if params[:tool] == 'force_timeout'
      launch_payload[:exp] = Time.now.to_i - 10          # just past it
    else
      launch_payload[:exp] = Time.now.to_i + 5 * 60    # five minutes from now
    end

    launch_form = JwtUtils.lti_launch_body("#{TOOL_PROVIDER}/tool_provider/lti_launch/#{params[:tool]}",
                                     launch_payload, TC_TP_SECRET, WirelogUtils.tc_wire_log, params[:tool], false)

    render inline: launch_form
  end

  def get_eventstore_access_jwt
    (jwt_payload, json_obj, error_msg) = JwtUtils.read_lti_service(request, TC_TP_SECRET, WirelogUtils.tc_wire_log)
    if error_msg.nil?
      new_jwt_payload = jwt_payload.clone
      new_jwt_payload.delete('exp')
      jwt = JwtUtils.create_jwt(TC_ES_SECRET, 12.hours, new_jwt_payload)
      render status: 200, json: {jwt: jwt}
    else
      render status: 500, json: {error_msg: error_msg}
    end
  end

  def index
    @payload_hash = create_payload_hash
    @results = Result.all
    session[:payload] = @payload_hash
    render 'tool_consumer/index.haml'
  end

  def launch_eventstore
    launch_payload = session[:payload]

    launch_form = JwtUtils.lti_launch_body("#{EVENT_STORE}/events/lti_launch",
                                           launch_payload, TC_ES_SECRET, WirelogUtils.tc_wire_log, 'Eventstore', false)

    render inline: launch_form
  end

  private

  def create_payload_hash
    payload_hash = ActiveSupport::HashWithIndifferentAccess.new
    payload_hash[:lti_version] = 'LTI-2p1'
    payload_hash[:lti_message_type] = 'jwt-lti-launch-request'
    payload_hash[:resource_link_id] = '429785226'
    payload_hash[:user_id] = 'jtibbetts'
    payload_hash[:roles] = 'Learner'
    payload_hash[:context_id] = 'math-101.781816'
    payload_hash[:context_type] = 'CourseSection'
    payload_hash[:launch_presentation_return_url] = "#{TOOL_CONSUMER}/tool_consumer"
    payload_hash[:launch_id] = SecureRandom.uuid
    payload_hash[:eventstore_profile_url] = "#{TOOL_CONSUMER}/tool_consumer/eventstore_profile"
    payload_hash
  end

end