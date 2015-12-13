#!/usr/bin/env bash
# The access token used in this script expires at 2015-12-13T19:21:16Z
if [ $# -eq 0 ]; then
    echo "usage: <scriptname> <numeric-score-value>"
    return 1
fi
prefix='{"isbn":"9780203370360","client":"unit_tester","results":[{"score":"'
suffix='", "location":"2-1","timestamp":"2015-12-13T14:21:16Z","metadata":"{}"}]}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXN1bHRfYWdlbnRfbGFiZWwiOiJhYmxlIiwiYWdlbnRfc2VjcmV0IjoiZGZlZDNjNWRmZGM4NTExNzE4ZTAxMWMxYTZlY2VkMzciLCJ1c2VyX2lkIjoianRpYmJldHRzIiwiY29udGV4dF9pZCI6Im1hdGgtMTAxLjc4MTgxNiIsInJlc291cmNlX2xpbmtfaWQiOiI0Mjk3ODUyMjYiLCJleHAiOjE0NTAwMTY3NzZ9.YrOiD7sb0JpyB2aAzpJcjkLmqQfiMbC_A0UsiEB7GSU' -d "$prefix$1$suffix" http://kinexis3001.ngrok.io/tool_provider/send_message