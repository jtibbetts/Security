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
printf '
script done
'