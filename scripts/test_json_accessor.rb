ja = ResultAgentAccessor.new('tp')
json = ja.fetch_result_agent('asdf')
puts json.inspect
json['foo'] = 'bar'
json['test'] = 'some'
ja.store_result_agent('asdf', json)


json = ja.fetch_result_agent('qwer')
puts json.inspect
json['able'] = 'one'
ja.store_result_agent('qwer', json)

puts "Count: #{ja.count_result_agents}"

