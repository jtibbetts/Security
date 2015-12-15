#!/usr/bin/env bash
# The access token used in this script expires at 2015-12-15T00:25:12Z
if [ $# -eq 0 ]; then
    echo "usage: <scriptname> <numeric-score-value>"
    return 1
fi
prefix='{"isbn":"9780203370360","client":"unit_tester","result_user":"jtibbetts","context_id":"math-101.781816", "results":[{"score":"'
suffix='", "location":"2-1","timestamp":"2015-12-14T19:25:12Z","metadata":"{}"}]}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXN1bHRfYWdlbnRfbGFiZWwiOiJiYWtlciIsImV4cCI6MTQ1MDEyMTQxMn0.rqcmiSw0f880SZ3rKxwvIjhryl1iriOxRT_w7hhE1Vk' -d "$prefix$1$suffix" http://kinexis3001.ngrok.io/tool_provider/send_message
printf '
result reported
'
# continue for result + event dispatch
evt_prefix='{"event_source":"REM","event_type":"action","event_name":"result", "event_value":"'
evt_suffix='"}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJldmVudHN0b3JlX3Nlc3Npb25faWQiOiIwOWVhZjlmNy02MGQwLTQ2YzEtOTYxYy04ZjVhNTk1NzMzNGYiLCJzZW5zb3JfaWQiOiJ0cC0xMjM0IiwiZXhwIjoxNDUwMTY0Mjk4fQ.0GlVSbVUl2MH1rnt4oyIWpQOakCLdNC4cnrTlgnXKUQ' -d "$evt_prefix$1$evt_suffix" http://kinexis3002.ngrok.io/events/post_event
printf '
event reported
'
printf '
script done
'