Rails.application.routes.draw do
  get 'tool_consumer/clear_log' => 'tool_consumer#clear_log'
  post 'tool_consumer/post_results' => 'post_results#create'

  get 'tool_consumer' => 'tool_consumer#index'
  post 'tool_consumer' => 'tool_consumer#create'

  get 'tool_provider/lti_launch/:tool' => 'tool_provider#lti_launch'
  post 'tool_provider/lti_launch/:tool' => 'tool_provider#lti_launch'

  post 'tool_provider/send_message' => 'send_message#create'

  post 'tool_provider/resource_harvester' => 'tool_provider#resource_harvester'
  get 'tool_provider/clear_session' => 'tool_provider#clear_session'
end
