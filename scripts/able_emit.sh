#!/usr/bin/env bash
# The access token used in this script expires at 2015-12-11T17:30:16Z
if [ $# -eq 0 ]; then
    echo "usage: <scriptname> <numeric-score-value>"
    return 1
fi
prefix='{"isbn":"9780203370360","client":"unit_tester","results":[{"score":"'
suffix='", "location":"2-1","timestamp":"2015-12-11T17:25:16Z","metadata":"{}"}]}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXN1bHRfYWdlbnRfbGFiZWwiOiJhYmxlIiwidXNlcl9pZCI6Imp0aWJiZXR0cyIsImNvbnRleHRfaWQiOiJtYXRoLTEwMS43ODE4MTYiLCJyZXNvdXJjZV9saW5rX2lkIjoiNDI5Nzg1MjI2IiwiZXhwIjoxNDQ5ODU1MDE2fQ.Hgh_v374UcUzzXllJQrK4bGSmoI8UFmsPhI-48wMrP8' -d "$prefix$1$suffix" http://kinexis3001.ngrok.io/tool_provider/send_message