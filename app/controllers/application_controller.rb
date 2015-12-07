class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # TOOL_PROVIDER = "http://kinexis3000.ngrok.io"
  # TOOL_CONSUMER = "http://kinexis3001.ngrok.io"

  TOOL_CONSUMER = "http://localhost:3000"
  TOOL_PROVIDER = "http://localhost:3001"

  JWT_SECRET = 'my$ecretK3y'
end
