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
if f.size < style_heading.size
  f.truncate(0)
  f.write(style_heading)
  f.close
end

Rails.application.config.tc_wire_log = WireLog.new "ToolConsumer", full_filename
Rails.application.config.tp_wire_log = WireLog.new "ToolProvider", full_filename
Rails.application.config.rem_wire_log = WireLog.new "Remote", full_filename

