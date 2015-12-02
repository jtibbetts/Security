
require "jwt"

payload = <<-eos
{"lti_message_type":"basic-lti-launch-request","lti_version":"LTI-1p0","resource_link_id":"429785226",
"resource_link_title":"Phone home","resource_link_description":"Will ET phone home, or not; click to discover more.",
"user_id":"29123","roles":"learner","lis_person_name_full":"John Logie Baird","lis_person_name_family":"Baird",
"lis_person_name_given":"John","lis_person_contact_email_primary":"jbaird@uni.ac.uk","lis_person_sourcedid":"sis:942a8dd9",
"user_image":"http://lti.tools/test/images/lti.gif","context_id":"S3294476","context_type":"CourseSection",
"context_title":"Telecommuncations 101","context_label":"ST101","lis_course_offering_sourcedid":"DD-ST101",
"tool_consumer_info_version":"1.2","tool_consumer_instance_guid":"vle.uni.ac.uk",
"tool_consumer_instance_name":"University of JISC"}
eos

payload = JSON.load(payload)

secret = 'my$ecretK3y'

exp = Time.now.to_i + 5 * 3600  # 5 minute grace period
jti = (rand * 10E12).to_i.to_s  # big random number

contents = {data: payload, exp: exp, jti: jti}

puts "contents: \n#{contents} encoded with #{secret}\n"

token = JWT.encode contents, secret, 'HS256'

puts "JWT ready to send: #{token}"

puts "***********decode JWT***********"

puts "***********media type = application/jwt"
decoded_token = JWT.decode token, secret, true, { :algorithm => 'HS256' }

puts "***********throws ExpiredSignature if past expiry************"
puts "***********check nonce dupe here--DO WE NEED THIS OVER SSL?*****************"
puts "parameter headers: \n#{decoded_token[1]}"
puts "decoded_token: \n#{decoded_token[0]}"

puts "token: \n#{token}"

