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
printf '
script done
'