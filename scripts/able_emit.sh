#!/usr/bin/env bash
# The access token used in this script expires at 2015-12-02T23:58:15Z
if [ $# -eq 0 ]; then
    echo "usage: <scriptname> <numeric-score-value>"
    return 1
fi
prefix='{"isbn":"9780203370360","client":"unit_tester","results":[{"score":"'
suffix='", "location":"2-1","timestamp":"2015-12-02T23:53:15Z","metadata":"{}"}]}'
CURL -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtZXRhc2Vzc2lvbl9pZCI6IjViNjhjODRiLTcyMzMtNGEzZi05ODdmLWJkNTRiMmRmMzliYSIsInVzZXJfaWQiOiJqdGliYmV0dHMiLCJjb250ZXh0X2lkIjoibWF0aC0xMDEuNzgxODE2IiwicmVzb3VyY2VfbGlua19pZCI6IjQyOTc4NTIyNiIsImV4cCI6MTQ0OTEwMDY5NX0.JFAYc5zl58GNevUyV-IiHA1KUoq2UN9WS9DfsiulCB8' -d "$prefix$1$suffix" http://kinexis3001.ngrok.io/tool_provider/send_message