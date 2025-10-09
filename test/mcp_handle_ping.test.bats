#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "mcp_handle_ping: should handle valid ping request" {
    local id="123"

    run mcp_handle_ping "${id}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":123'
    assert_output --partial '"result":{}'
}

@test "mcp_handle_ping: should handle ping request with numeric id" {
    local id="456"

    run mcp_handle_ping "${id}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":456'
    assert_output --partial '"result":{}'
}

@test "mcp_handle_ping: should handle ping request with null id" {
    local id="null"

    run mcp_handle_ping "${id}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":null'
    assert_output --partial '"result":{}'
}

@test "mcp_handle_ping: should handle ping request with string id" {
    local id='"ping-test-id"'

    run mcp_handle_ping "${id}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":"ping-test-id"'
    assert_output --partial '"result":{}'
}

@test "mcp_handle_ping: should fail with invalid id" {
    local id="invalid-id-format-with-special-chars@#$"

    run mcp_handle_ping "${id}"
    assert_failure
}
