class ToolProviderController  < ApplicationController
  skip_before_action :verify_authenticity_token

  EXPIRY_MINUTES = 5

  TOOL_PROVIDER = 'tp'
  before_filter do |controller|
    @tp_accessor = JsonAccessor.new(TOOL_PROVIDER)
  end


  def lti_launch
    if request.post?
      jwt_payload = params[:jwt_payload]
      tool = params[:tool]

      # TESTING: break a secret
      if tool == 'munge_secret'
        secret = 'bad_secret'
      else
        secret = JWT_SECRET
      end

      # TESTING: break the payload
      if tool == 'munge_payload'
        jwt_payload = '12341234.4567456775.BADBAD'
      end

      (payload, headers, error_msg) = JwtUtils.decode_jwt(jwt_payload, secret)

      tp_wire_log = Rails.application.config.tp_wire_log

      if error_msg.nil?
        JwtUtils.log_payload(tp_wire_log, jwt_payload, JWT_SECRET)
      else
        tp_wire_log.log("JWT Error: #{error_msg}")
        raise error_msg
      end

      tool = 'echo' unless self.respond_to? tool
      self.public_send(tool, payload )
    else
      launch_resource()
    end
  end

  def echo params_hash
    outbuf = ''
    outbuf << '<h1>Echo payload</h1><pre>'
    outbuf << JSON.pretty_generate(params_hash)
    outbuf << '</pre>'

    render inline: outbuf
  end

  def debug params_hash
    outbuf = ''
    outbuf << '<h1>Debug</h1>'
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

    render inline: outbuf
  end

  def launch_resource params_hash=nil
    @metasession_id = SecureRandom.uuid
    session[:current_metasession_id] = @metasession_id
    if params_hash.present?
      session[:current_user_id] = params_hash['user_id']
      session[:current_context_id] = params_hash['context_id']
      session[:current_resource_link_id] = params_hash['resource_link_id']
    end

    # this 'fetch' initializes the metasession entry
    @entries = @tp_accessor.fetch_entries()

    outbuf = ''
    outbuf << '<h1>Launch resource</h1>'

    render 'tool_provider/result_harvester.haml'
  end

  def resource_harvester
    metasession_id = session[:current_metasession_id]
    @entry = @tp_accessor.fetch_entry(metasession_id)
    begin
      metasession_label = params[:metasession_label]

      jwt_payload = JwtUtils.create_jwt_bearer_token(EXPIRY_MINUTES,
                                            metasession_id: metasession_id,
                                            user_id: session[:current_user_id],
                                            context_id: session[:current_context_id],
                                            resource_link_id: session[:current_resource_link_id])

      emit_result_script(metasession_label, jwt_payload, Time.now + EXPIRY_MINUTES.minutes)

      @entry['label'] = metasession_label
      @entry['user_id'] = session['current_user_id']
      @entry['context_id'] = session['current_context_id']
      @entry['resource_link_id'] = session['current_resource_link_id']
      @entry['results'] = []
    ensure
      @tp_accessor.store_entry(metasession_id, @entry)
    end

    redirect_to '/tool_provider/lti_launch/launch_resource'
  end

  def clear_session
    @tp_accessor.clear_entries
    session[:current_metasession_id] = nil
    Dir.glob('scripts/*_emit.sh').each {|fname| File.delete(fname)}
    redirect_to '/tool_provider/lti_launch/launch_resource'
  end

  private

  def emit_result_script(label, jwt_payload, expiry_stamp)
    outbuf = ""
    outbuf += %Q(#!/usr/bin/env bash\n)
    outbuf += %Q(# The access token used in this script expires at #{Time.at(expiry_stamp).utc.iso8601}\n)
    outbuf += %Q(if [ $# -eq 0 ]; then\n)
    outbuf += %Q(    echo "usage: <scriptname> <numeric-score-value>"\n)
    outbuf += %Q(    return 1\n)
    outbuf += %Q(fi\n)
    outbuf += %Q(prefix='{"isbn":"9780203370360","client":"unit_tester","results":[{"score":"'\n)
    outbuf += %Q(suffix='", "location":"2-1","timestamp":"#{Time.now.utc.iso8601}","metadata":"{}"}]}'\n)
    outbuf += %Q(CURL -H 'Authorization: Bearer #{jwt_payload}' )
    outbuf += %Q(-d "$prefix$1$suffix" )
    outbuf += %Q(http://kinexis3001.ngrok.io/tool_provider/send_message)

    fname = "scripts/#{label}_emit.sh"
    File.open(fname, "w") { |file| file.write outbuf }
    File.open(fname).chmod(0755)

    tp_wire_log = Rails.application.config.tp_wire_log
    tp_wire_log.log("Create data source:")
    tp_wire_log.log(outbuf)
  end
end