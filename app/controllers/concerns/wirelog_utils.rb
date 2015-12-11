class WirelogUtils
  def self.tc_wire_log
    Rails.application.config.tc_wire_log
  end

  def self.tp_wire_log
    Rails.application.config.tp_wire_log
  end

  def self.rem_wire_log
    Rails.application.config.rem_wire_log
  end

  def self.log_response(wirelog, response, title = nil)
    timestamp
    wirelog.raw_log(title.nil? ? 'Response' : "Response: #{title}")
    wirelog.raw_log("Status: #{response.code} #{STATUS_CODES[response.code]}")
    headers = response.headers
    unless headers.blank?
      wirelog.raw_log('Headers:')
      headers.each { |k, v| wirelog.raw_log("#{k}: #{v}") if k.downcase =~ /^content/ }
    end

    if response.body
      # the following is expensive so do only when needed
      wirelog.raw_log('Body:') if @is_logging
      begin
        json_obj = JSON.load(response.body)
        wirelog.raw_log(JSON.pretty_generate(json_obj))
      rescue
        wirelog.raw_log("#{response.body}")
      end
    end
    wirelog.newline
    wirelog.flush(css_class: "#{@wire_log_name}wirelog.")
  end

  def self.write_wirelog_header(wire_log, title, method, uri, headers = {},
      parameters = {}, body = nil, output_parameters = {})
    wire_log.timestamp
    wire_log.raw_log((title.nil?) ? 'LtiService' : "LtiService: #{title}")
    wire_log.raw_log("#{method.upcase} #{uri}")
    unless headers.blank?
      wire_log.raw_log('Headers:')
      headers.each { |k, v| wire_log.raw_log("#{k}: #{v}") }
    end
    parameters.each { |k, v| output_parameters[k] = v unless k =~ /^oauth_/ }

    if output_parameters.length > 0
      wire_log.raw_log('Parameters:')
      output_parameters.each { |k, v| wire_log.raw_log("#{k}: #{v}") }
    end
    if body
      wire_log.raw_log('Body:')
      wire_log.raw_log(body)
    end
    wire_log.newline
    wire_log.flush
  end

  def write_response(response, title = nil)
    timestamp
    raw_log(title.nil? ? 'Response' : "Response: #{title}")
    raw_log("Status: #{response.code} #{STATUS_CODES[response.code]}")
    headers = response.headers
    unless headers.blank?
      raw_log('Headers:')
      headers.each { |k, v| raw_log("#{k}: #{v}") if k.downcase =~ /^content/ }
    end

    if response.body
      # the following is expensive so do only when needed
      raw_log('Body:') if @is_logging
      begin
        json_obj = JSON.load(response.body)
        raw_log(JSON.pretty_generate(json_obj))
      rescue
        raw_log("#{response.body}")
      end
    end
    newline
    flush(css_class: "#{@wire_log_name}Response")
  end

end