#!/usr/bin/env bats

setup() {
    load "${BATS_TEST_DIRNAME}/../mcbox-core.bash"
}

@test "jsonrpc_validate_id: accepts no arguments (notification)" {
    run jsonrpc_validate_id
    [ "${status}" -eq 0 ]
}

@test "jsonrpc_validate_id: accepts null" {
    run jsonrpc_validate_id "null"
    [ "${status}" -eq 0 ]
}

@test "jsonrpc_validate_id: accepts JSON-formatted string" {
    run jsonrpc_validate_id '"test-id"'
    [ "${status}" -eq 0 ]
}

@test "jsonrpc_validate_id: accepts plain string" {
    run jsonrpc_validate_id "test-id"
    [ "${status}" -eq 0 ]
}

@test "jsonrpc_validate_id: accepts integer number" {
    run jsonrpc_validate_id "123"
    [ "${status}" -eq 0 ]
}

@test "jsonrpc_validate_id: accepts zero" {
    run jsonrpc_validate_id "0"
    [ "${status}" -eq 0 ]
}

@test "jsonrpc_validate_id: rejects negative integer" {
    run jsonrpc_validate_id "-456"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_validate_id: rejects fractional number" {
    run jsonrpc_validate_id "123.45"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_validate_id: rejects boolean true" {
    run jsonrpc_validate_id "true"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_validate_id: rejects boolean false" {
    run jsonrpc_validate_id "false"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_validate_id: rejects array" {
    run jsonrpc_validate_id '["test"]'
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_validate_id: rejects object" {
    run jsonrpc_validate_id '{"test": "value"}'
    [ "${status}" -eq 1 ]
}
