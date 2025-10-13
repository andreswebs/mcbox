#!/usr/bin/env bats

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup_file() {
    # shellcheck disable=SC2329
    function call_tool() {
        "${BATS_TEST_DIRNAME}/helpers/smoketest-call-tool.bash" "${@}"
    }

    export -f call_tool
}

@test "call tool: smoketest" {
    run call_tool mcbox:smoketest
    assert_success
    assert_output --partial '"text": "ok"'
}

@test "call tool: smoketest_fail" {
    run call_tool mcbox:smoketest_fail
    assert_success
    assert_output --partial '"text": ""'
    assert_output --partial '"isError": true'
}

@test "call tool: echo_token" {
    TOKEN=$(head -c 32 /dev/urandom | base64)

    run call_tool mcbox:echo_token --args '{"token":"'"${TOKEN}"'"}'

    assert_success
    assert_output --partial '"token": "'"${TOKEN}"'"'
}

@test "call tool: echo_token_fail" {
    TOKEN=$(head -c 32 /dev/urandom | base64)

    run call_tool mcbox:echo_token_fail --args '{"token":"'"${TOKEN}"'"}'

    assert_failure
    assert_output --partial '"error": "MCP error -32603: Internal error: tool output does not match outputSchema"'
}
