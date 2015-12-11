class ResultAgentAccessor
   def self.access_result_agent(result_agent_label)
    result_agents = ResultAgent.where(result_agent_label: result_agent_label)
    if result_agents.present?
      result = result_agents.first
    else
      result = ResultAgent.create(result_agent_label: result_agent_label, json_str: '{}')
    end
    result
  end

  def self.clear_result_agents()
    ResultAgent.destroy_all
  end

  def self.count_result_agents()
    ResultAgent.count
  end

  def self.fetch_result_agents()
    results = []
    fetch_result_agent_ids.each do |entry|
      results << fetch_result_agent(entry)
    end
    results
  end

  def self.fetch_result_agent(result_agent_label)
    json_store = access_result_agent(result_agent_label)
    json = JSON.load(json_store.json_str)
    json['result_agent_label'] = result_agent_label
    json
  end

  def self.fetch_result_agent_ids
    ResultAgent.all.pluck(:result_agent_label)
  end

  def self.store_result_agent(result_agent_label, json)
    json.delete('result_agent_label')
    json_str = json.nil? ? '{}' : json.to_json
    result_agent = access_result_agent(result_agent_label)
    result_agent.result_agent_label = result_agent_label
    result_agent.json_str = json_str
    result_agent.save
  end
end