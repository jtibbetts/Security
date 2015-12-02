prefix='"{"isbn":"9780203370360","client":"unit_tester","results":[{"score":"'
suffix='", "location":"2-1","timestamp":"2015-05-01T20:00:21Z","metadata":"{}"}]}"'
CURL -H 'Authorization: Bearer c5b4b5ce-0e60-4028-b37d-5545c9dab30c' -d '$prefix$1$suffix' http://kinexis3001.ngrok.io/tool_provider/send_message