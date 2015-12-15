#!/usr/bin/env bash
# The access token used in this script expires at 2015-12-15T21:37:57Z
if [ $# -eq 0 ]; then
    echo "usage: <scriptname> <numeric-score-value>"
    return 1
fi
prefix='{"isbn":"9780203370360","client":"unit_tester","result_user":"jtibbetts","context_id":"math-101.781816", "results":[{"score":"'
suffix='", "location":"2-1","timestamp":"2015-12-15T16:37:57Z","metadata":"{}"}]}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXN1bHRfYWdlbnRfbGFiZWwiOiJhYmxlIiwiZXhwIjoxNDUwMTk3Nzc3fQ.y7yTGJUGGhfe2uRiSjfOhDNeDjqQBf6wJ1XFRV40pnA' -d "$prefix$1$suffix" http://kinexis3001.ngrok.io/tool_provider/send_message
printf '
result reported
'
# continue for result + event dispatch
evt_prefix='{"event_source":"REM","event_type":"action","event_name":"result", "event_value":"'
evt_suffix='"}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJldmVudHN0b3JlX3Nlc3Npb25faWQiOiIzNmMwYjdjNS1hMjU5LTRmNmUtOWFmNi0zMWM2ZGIyODk0MjYiLCJzZW5zb3JfaWQiOiJ0cC0xMjM0IiwiZXhwIjoxNDUwMjQwNjY5fQ.u6OcwQqg1ORLm_0RvpehrpB_fcjVW3eMCnW1JeJreBs' -d "$evt_prefix$1$evt_suffix" http://kinexis3002.ngrok.io/events/post_event
printf '
event reported
'
printf '
script done
'