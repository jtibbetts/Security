class ToolProviderController  < ApplicationController
  skip_before_action :verify_authenticity_token

  TOOL_PROVIDER_CODE = 'tp'
  TP_SENSOR_ID = "#{TOOL_PROVIDER_CODE}-1234"
  RESULT_AGENT_PREFIX = 'RESULT_AGENT-'

  def lti_launch
    if request.post?
      jwt_payload = params[:jwt_payload]
      tool = params[:tool]

        # TESTING: break a secret
      if tool == 'munge_secret'
        secret = 'bad_secret'
      else
        secret = TC_TP_SECRET
      end

      # TESTING: break the payload
      if tool == 'munge_payload'
        jwt_payload = '12341234.4567456775.BADBAD'
      end

      (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt_payload, secret)
      if error_msg.present?
        raise "Authentication failure: #{error_msg}"
      end

      # get events endpoint

      session[:eventstore_session_id] = payload['eventstore_session_id']
      session[:eventstore_access_jwt] = get_eventstore_access_jwt(session[:eventstore_session_id], TP_SENSOR_ID)

      emit_event('Event-->Tool launched', WirelogUtils.tp_wire_log, session[:eventstore_access_jwt],
                 'lti_launch', 'TP', 'launched', 'entry', tool)


       tool = 'echo' unless self.respond_to? tool
      self.public_send(tool, payload )
    else
      launch_resource()
    end
  end

  def echo params_hash
    outbuf = ''
    outbuf << '<h1>LTI Tool Consumer:  Echo</h1><pre>'
    outbuf << JSON.pretty_generate(params_hash)
    outbuf << '</pre>'

    outbuf << return_to_tool_consumer(params_hash['launch_presentation_return_url'])

    render inline: outbuf
  end

  def debug params_hash
    outbuf = ''
    outbuf << '<h1>LTI Tool Consumer:  Debug</h1><pre>'
    outbuf << '<h2>Echo JWT message</h2>'
    outbuf << '<pre>'
    outbuf << params[:jwt_payload]
    outbuf << '</pre>'

    outbuf << '<h2>Base64 decoded</h2>'
    outbuf << '<pre>'
    zones = params[:jwt_payload].split('.')
    outbuf << '<h3>header</h3>'
    outbuf << JSON.pretty_generate(JSON.load(Base64.decode64(zones[0])))
    outbuf << '<h3>payload</h3>'
    outbuf << JSON.pretty_generate(JSON.load(Base64.decode64(zones[1])))
    outbuf << '</pre>'

    outbuf << return_to_tool_consumer(params_hash['launch_presentation_return_url'])

    render inline: outbuf
  end

  def launch_resource params_hash=nil
    if params_hash.present?
      session[:current_user_id] = params_hash['user_id']
      session[:current_context_id] = params_hash['context_id']
      session[:current_resource_link_id] = params_hash['resource_link_id']
      session[:eventstore_profile_url] = params_hash['eventstore_profile_url']
      session[:return_url] = params_hash['launch_presentation_return_url']
      @result_agent_id = session[:result_agent_id]
    end

    # this 'fetch' initializes the result_agents entry
    @result_agents = ResultAgentAccessor.fetch_result_agents()

    outbuf = ''
    outbuf << '<h1>Launch resource</h1>'

    render 'tool_provider/result_harvester.haml'
  end

  def resource_harvester
    result_agent_label = params[:result_agent_label]
    @result_agent = ResultAgentAccessor.fetch_result_agent(result_agent_label)
    begin
      # jwt for use by CURL script...add a per-agent secret (extra credit)
      agent_secret = SecureRandom.hex
      jwt_payload = JwtUtils.create_jwt(TC_TP_SECRET, EXPIRY_STANDARD,
                                            result_agent_label: result_agent_label)

      # emit result script
      emit_result_script(result_agent_label, session['current_user_id'], session['current_context_id'],
                         Time.now + EXPIRY_STANDARD.minutes, jwt_payload)

      # emit result + event script
      emit_result_script(result_agent_label, session['current_user_id'], session['current_context_id'],
                         Time.now + EXPIRY_STANDARD.minutes, jwt_payload, session[:eventstore_access_jwt])

      eventstore_access_jwt = session[:eventstore_access_jwt]

      @result_agent['context_id'] = session['current_context_id']
      @result_agent['eventstore_access_jwt'] = eventstore_access_jwt
      @result_agent['results'] = []

      emit_event("Event-->create result agent", WirelogUtils.tp_wire_log, eventstore_access_jwt, result_agent_label,
                 'TP', 'session', 'create_emitter', result_agent_label)
    ensure
      ResultAgentAccessor.store_result_agent(result_agent_label, @result_agent)
      @result_agents = ResultAgentAccessor.fetch_result_agents()
    end

    redirect_to '/tool_provider/lti_launch/launch_resource'
  end

  def clear_session
    ResultAgentAccessor.clear_result_agents
    session[:current_result_agent_label] = nil
    Dir.glob('scripts/*_emit.sh').each {|fname| File.delete(fname)}
    Dir.glob('scripts/*_event.sh').each {|fname| File.delete(fname)}
    redirect_to '/tool_provider/lti_launch/launch_resource'
  end

  private

  def emit_result_script(label, result_user, context_id, expiry_stamp, result_jwt, eventstore_access_jwt=nil)
    outbuf = ""
    outbuf += %Q(#!/usr/bin/env bash\n)
    outbuf += %Q(# The access token used in this script expires at #{Time.at(expiry_stamp).utc.iso8601}\n)
    outbuf += %Q(if [ $# -eq 0 ]; then\n)
    outbuf += %Q(    echo "usage: <scriptname> <numeric-score-value>"\n)
    outbuf += %Q(    return 1\n)
    outbuf += %Q(fi\n)
    outbuf += %Q(prefix='{"isbn":"9780203370360","client":"unit_tester","result_user":"#{result_user}",)
    outbuf += %Q("context_id":"#{context_id}", "results":[{"score":"'\n)
    outbuf += %Q(suffix='", "location":"2-1","timestamp":"#{Time.now.utc.iso8601}","metadata":"{}"}]}'\n)
    outbuf += %Q(CURL -H 'Authorization: Bearer #{result_jwt}' )
    outbuf += %Q(-d "$prefix$1$suffix" )
    outbuf += %Q(#{TOOL_PROVIDER}/tool_provider/send_message\n)
    outbuf += %Q(printf '\nresult reported\n'\n)

    if eventstore_access_jwt.present?
      outbuf += %Q(# continue for result + event dispatch\n)
      outbuf += %Q(evt_prefix='{"event_source":"REM","event_type":"action",)
      outbuf += %Q("event_name":"result", "event_value":"'\n)
      outbuf += %Q(evt_suffix='"}'\n)
      outbuf += %Q(CURL -H 'Authorization: Bearer #{eventstore_access_jwt}' )
      outbuf += %Q(-d "$evt_prefix$1$evt_suffix" )
      outbuf += %Q(#{EVENT_STORE}/events/post_event\n)
      outbuf += %Q(printf '\nevent reported\n'\n)
    end

    outbuf += %Q(printf '\nscript done\n')

    fname_suffix = eventstore_access_jwt.blank? ? '_emit.sh' : '_event.sh'
    fname = "scripts/#{label}#{fname_suffix}"
    File.open(fname, "w") { |file| file.write outbuf }
    File.open(fname).chmod(0755)

    tp_wire_log = Rails.application.config.tp_wire_log
    tp_wire_log.log("Create data source:")
    tp_wire_log.log(outbuf)
  end

  def return_to_tool_consumer(return_url)
    outbuf = ""
    outbuf += %Q(\n<p><p>\n)
    outbuf += %Q(<input type="button" value="Return to tool consumer" )
    outbuf += %Q(onclick="window.location=')
    outbuf += return_url
    outbuf += %Q('; return false;".>\n)
  end
end