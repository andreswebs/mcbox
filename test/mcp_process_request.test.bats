#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup_file() {
    export MCBOX_SERVER_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.server.json"
    export MCBOX_TOOLS_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.tools.json"
    export MCBOX_TOOLS_LIB_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.tools.bash"

    mcbox_load_config
}

teardown_file() {
    unset MCBOX_SERVER_CONFIG_FILE
    unset MCBOX_TOOLS_CONFIG_FILE
    unset MCBOX_TOOLS_LIB_FILE
}

@test "mcp_process_request: should ignore empty input" {
    local input=""

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should handle valid initialize request" {
    local input='{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2025-06-18"}}'

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should reject non-JSON-RPC 2.0 requests" {
    local input='{"jsonrpc": "1.0", "id": 1, "method": "initialize", "params": {}}'

    run mcp_process_request "${input}"
    assert_success
    assert_output --partial "Invalid request"
}

@test "mcp_process_request: should handle tools/list request" {
    local input='{"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}}'

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should handle tools/call request" {
    local input='{"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": "smoketest", "arguments": {}}}'

    run mcp_process_request "${input}"
    assert_success
    assert_output --partial '"result":'
}

@test "mcp_process_request: should handle notification requests" {
    local input='{"jsonrpc": "2.0", "method": "notifications/initialized"}'

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should reject unknown methods" {
    local input='{"jsonrpc": "2.0", "id": 4, "method": "unknown/method", "params": {}}'

    run mcp_process_request "${input}"
    assert_success
    assert_output --partial "Method not found: unknown/method"
}

@test "mcp_process_request: should handle malformed JSON" {
    local input='{"jsonrpc": "2.0", "id": 5, "method": "initialize"'

    run mcp_process_request "${input}"
    assert_success
    assert_output --partial '"error":'
    assert_output --partial '"code":-32700'
    assert_output --partial '"message":"Parse error"'
}

@test "mcp_process_request: should return proper error response for malformed JSON with null id" {
    local input='invalid json here'

    run mcp_process_request "${input}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":null'
    assert_output --partial '"error":'
    assert_output --partial '"code":-32700'
    assert_output --partial '"message":"Parse error"'
}

@test "mcp_process_request: should handle missing required fields" {
    local input='{"jsonrpc": "2.0", "id": 6}'

    run mcp_process_request "${input}"
    assert_success
    assert_output --partial '"error":'
    assert_output --partial '"code":-32600'
    assert_output --partial '"message":"Invalid request"'
}

@test "mcp_process_request: should handle null id in request" {
    local input='{"jsonrpc": "2.0", "id": null, "method": "initialize", "params": {"protocolVersion": "2025-06-18"}}'

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should handle numeric id in request" {
    local input='{"jsonrpc": "2.0", "id": 42, "method": "initialize", "params": {"protocolVersion": "2025-06-18"}}'

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should handle string id in request" {
    local input='{"jsonrpc": "2.0", "id": "test-id", "method": "initialize", "params": {"protocolVersion": "2025-06-18"}}'

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should handle request with no params" {
    local input='{"jsonrpc": "2.0", "id": 7, "method": "tools/list"}'

    run mcp_process_request "${input}"
    assert_success
}

@test "mcp_process_request: should handle ping request" {
    local input='{"jsonrpc": "2.0", "id": "ping-test", "method": "ping"}'

    run mcp_process_request "${input}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":"ping-test"'
    assert_output --partial '"result":{}'
}
