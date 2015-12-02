ja = JsonAccessor.new('tp')
json = ja.fetch_entry('asdf')
puts json.inspect
json['foo'] = 'bar'
json['test'] = 'some'
ja.store_entry('asdf', json)


json = ja.fetch_entry('qwer')
puts json.inspect
json['able'] = 'one'
ja.store_entry('qwer', json)

puts "Count: #{ja.count_entries}"

