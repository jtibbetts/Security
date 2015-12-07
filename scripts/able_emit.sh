#!/usr/bin/env bash
# The access token used in this script expires at 2015-12-06T14:51:25Z
if [ $# -eq 0 ]; then
    echo "usage: <scriptname> <numeric-score-value>"
    return 1
fi
prefix='{"isbn":"9780203370360","client":"unit_tester","results":[{"score":"'
suffix='", "location":"2-1","timestamp":"2015-12-06T14:46:25Z","metadata":"{}"}]}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtZXRhc2Vzc2lvbl9pZCI6ImFiMDc2ZDZhLWVhM2YtNGYyYi04NTljLTQzMDdjYzhjZGI2MCIsInVzZXJfaWQiOiJqdGliYmV0dHMiLCJjb250ZXh0X2lkIjoibWF0aC0xMDEuNzgxODE2IiwicmVzb3VyY2VfbGlua19pZCI6IjQyOTc4NTIyNiIsImV4cCI6MTQ0OTQxMzQ4NX0.soGAmCbDMYos0vZNUHk_CqhxbDf9rJmnyHi9OmR68K8' -d "$prefix$1$suffix" http://localhost:3001/tool_provider/send_message