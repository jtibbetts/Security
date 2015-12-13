class WirelogUtils

  STATUS_CODES = {
      100 => 'Continue',
      101 => 'Switching Protocols',
      102 => 'Processing',

      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      203 => 'Non-Authoritative Information',
      204 => 'No Content',
      205 => 'Reset Content',
      206 => 'Partial Content',
      207 => 'Multi-Status',
      226 => 'IM Used',

      300 => 'Multiple Choices',
      301 => 'Moved Permanently',
      302 => 'Found',
      303 => 'See Other',
      304 => 'Not Modified',
      305 => 'Use Proxy',
      307 => 'Temporary Redirect',

      400 => 'Bad Request',
      401 => 'Unauthorized',
      402 => 'Payment Required',
      403 => 'Forbidden',
      404 => 'Not Found',
      405 => 'Method Not Allowed',
      406 => 'Not Acceptable',
      407 => 'Proxy Authentication Required',
      408 => 'Request Timeout',
      409 => 'Conflict',
      410 => 'Gone',
      411 => 'Length Required',
      412 => 'Precondition Failed',
      413 => 'Request Entity Too Large',
      414 => 'Request-URI Too Long',
      415 => 'Unsupported Media Type',
      416 => 'Requested Range Not Satisfiable',
      417 => 'Expectation Failed',
      422 => 'Unprocessable Entity',
      423 => 'Locked',
      424 => 'Failed Dependency',
      426 => 'Upgrade Required',

      500 => 'Internal Server Error',
      501 => 'Not Implemented',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      504 => 'Gateway Timeout',
      505 => 'HTTP Version Not Supported',
      507 => 'Insufficient Storage',
      510 => 'Not Extended'
  }

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
    wirelog.timestamp
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