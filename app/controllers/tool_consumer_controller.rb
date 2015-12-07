class ToolConsumerController < ApplicationController

  def clear_log
    Rails.application.config.tc_wire_log.clear_log
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

    tc_wire_log = Rails.application.config.tc_wire_log
    launch_form = JwtUtils.lti_launch_body("#{TOOL_PROVIDER}/tool_provider/lti_launch/#{params[:tool]}",
                                     launch_payload, JWT_SECRET, tc_wire_log, params[:tool])

    render inline: launch_form
  end

  def index
    @payload_hash = create_payload_hash
    session[:payload] = @payload_hash
    render 'tool_consumer/index.haml'
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
    payload_hash
  end

  def create_lti_message(launch_url, form_params, title)
    body = ''
    body +=       %Q(
<div id="ltiLaunchFormSubmitArea">
  <form action="#{launch_url}"
    name="ltiLaunchForm" id="ltiLaunchForm" method="post"
    encType="application/x-www-form-urlencoded">
)
    form_params.each_pair do |k, v|
      body += %Q(      <input type="hidden" name="#{k}" value="#{CGI.escapeHTML(v)}"/>\n)
    end

    body += %Q{  </form>
</div>
<script language="javascript">
  document.ltiLaunchForm.submit();
</script>
      }

    tc_wire_log = Rails.application.config.tc_wire_log
    if tc_wire_log
      tc_wire_log.timestamp
      tc_wire_log.raw_log((title.nil?) ? 'LtiMessage' : "LtiMessage: #{title}")
      tc_wire_log.raw_log "LaunchUrl: #{launch_url}"
      tc_wire_log.raw_log body.strip
      tc_wire_log.newline
      tc_wire_log.flush
    end

    body
  end

end