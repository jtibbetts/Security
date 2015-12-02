
require "jwt"

payload = <<-eos
{"lti_message_type":"basic-lti-launch-request","lti_version":"LTI-1p0","resource_link_id":"429785226",
"resource_link_title":"Phone home","resource_link_description":"Will ET phone home, or not; click to discover more.",
"user_id":"29123","roles":"learner","lis_person_name_full":"John Logie Baird","lis_person_name_family":"Baird",
"lis_person_name_given":"John","lis_person_contact_email_primary":"jbaird@uni.ac.uk","lis_person_sourcedid":"sis:942a8dd9",
"user_image":"http://lti.tools/test/images/lti.gif","context_id":"S3294476","context_type":"CourseSection",
"context_title":"Telecommuncations 101","context_label":"ST101","lis_course_offering_sourcedid":"DD-ST101",
"lis_course_section_sourcedid":"DD-ST101:C1","tool_consumer_info_product_family_code":"jisc",
"tool_consumer_info_version":"1.2","tool_consumer_instance_guid":"vle.uni.ac.uk",
"tool_consumer_instance_name":"University of JISC",
"tool_consumer_instance_description":"A Higher Education establishment in a land far, far away.",
"tool_consumer_instance_contact_email":"vle@uni.ac.uk","tool_consumer_instance_url":"https://vle.uni.ac.uk/",
"launch_presentation_return_url":"http://lti.tools/test/tc-return.php","launch_presentation_css_url":"http://lti.tools/test/css/tc.css",
"launch_presentation_locale":"en-GB","launch_presentation_document_target":"frame",
"lis_outcome_service_url":"http://lti.tools/test/tc-outcomes.php",
"lis_result_sourcedid":"ba64f61c266faf1539d3879d6876ae94:::S3294476:::29123:::dyJ86SiwwA9",
"ext_ims_lis_basic_outcome_url":"http://lti.tools/test/tc-ext-outcomes.php","ext_ims_lis_resultvalue_sourcedids":"decimal",
"ext_ims_lis_memberships_url":"http://lti.tools/test/tc-ext-memberships.php",
"ext_ims_lis_memberships_id":"ba64f61c266faf1539d3879d6876ae94:::4jflkkdf9s",
"ext_ims_lti_tool_setting_url":"http://lti.tools/test/tc-ext-setting.php",
"ext_ims_lti_tool_setting_id":"ba64f61c266faf1539d3879d6876ae94:::d94gjklf954kj",
"custom_tc_profile_url":"http://lti.tools/test/tc-profile.php/ba64f61c266faf1539d3879d6876ae94",
"custom_system_setting_url":"http://lti.tools/test/tc-settings.php/system/ba64f61c266faf1539d3879d6876ae94",
"custom_context_setting_url":"http://lti.tools/test/tc-settings.php/context/ba64f61c266faf1539d3879d6876ae94",
"custom_link_setting_url":"http://lti.tools/test/tc-settings.php/link/ba64f61c266faf1539d3879d6876ae94",
"custom_lineitems_url":"http://lti.tools/test/tc-outcomes2.php/ba64f61c266faf1539d3879d6876ae94/S3294476/lineitems",
"custom_results_url":"http://lti.tools/test/tc-outcomes2.php/ba64f61c266faf1539d3879d6876ae94/S3294476/lineitems/dyJ86SiwwA9/results",
"custom_lineitem_url":"http://lti.tools/test/tc-outcomes2.php/ba64f61c266faf1539d3879d6876ae94/S3294476/lineitems/dyJ86SiwwA9",
"custom_result_url":"http://lti.tools/test/tc-outcomes2.php/ba64f61c266faf1539d3879d6876ae94/S3294476/lineitems/dyJ86SiwwA9/results/29123",
"custom_context_memberships_url":"http://lti.tools/test/tc-memberships.php/context/ba64f61c266faf1539d3879d6876ae94",
"custom_link_memberships_url":"http://lti.tools/test/tc-memberships.php/link/ba64f61c266faf1539d3879d6876ae94"}
eos

payload = JSON.load(payload)

secret = 'my$ecretK3y'

puts "payload: \n#{payload} encoded with #{secret}\n"

launch_payload = {'message_type' => 'jwt_message', 'launch_jwt' => payload}

token = JWT.encode launch_payload, secret, 'HS256'

puts "JWT ready to send: #{token}"

puts "***********decode JWT***********"

decoded_token = JWT.decode token, secret, true, { :algorithm => 'HS256' }

puts "parameter headers: \n#{decoded_token[1]}"
puts "decoded_token: \n#{decoded_token[0]}"

token = decoded_token[0]['launch_jwt']

puts "token: \n#{token}"

