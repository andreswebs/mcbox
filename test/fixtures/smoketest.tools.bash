#!/usr/bin/env bash

function tool_smoketest() {
    echo "ok"
}

function tool_smoketest_fail() {
    return 1
}

function tool_echo_token() {
    local arguments="${1}"
    local token
    token=$(echo "${arguments}" | jq --raw-output '.token')
    jq --compact-output --null-input --arg token "${token}" '{"token": $token}'
}

function tool_echo_token_fail() {
    echo '{"invalid_field":"value"}'
}


export -f tool_smoketest tool_smoketest_fail tool_echo_token tool_echo_token_fail
