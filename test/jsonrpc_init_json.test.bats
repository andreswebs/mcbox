#!/usr/bin/env bats
# shellcheck shell=bats

load '../mcbox-core.bash'

@test "jsonrpc_init_json: should create base JSON-RPC object without ID (notification)" {
    local expected='{"jsonrpc":"2.0"}'

    run jsonrpc_init_json
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "jsonrpc_init_json: should create JSON-RPC object with null ID" {
    local expected='{"jsonrpc":"2.0","id":null}'

    run jsonrpc_init_json "null"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "jsonrpc_init_json: should create JSON-RPC object with string ID" {
    local expected='{"jsonrpc":"2.0","id":"test-id"}'

    run jsonrpc_init_json "test-id"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "jsonrpc_init_json: should create JSON-RPC object with numeric ID" {
    local expected='{"jsonrpc":"2.0","id":123}'

    run jsonrpc_init_json "123"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "jsonrpc_init_json: should create JSON-RPC object with zero ID" {
    local expected='{"jsonrpc":"2.0","id":0}'

    run jsonrpc_init_json "0"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "jsonrpc_init_json: should handle empty string ID as no ID" {
    local expected='{"jsonrpc":"2.0"}'

    run jsonrpc_init_json ""
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "jsonrpc_init_json: should fail with invalid ID (negative number)" {
    local expected='{"jsonrpc":"2.0","id":-456}'

    run jsonrpc_init_json "-456"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_init_json: should fail with invalid ID (fractional number)" {
    run jsonrpc_init_json "123.45"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_init_json: should fail with invalid ID (boolean true)" {
    run jsonrpc_init_json "true"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_init_json: should fail with invalid ID (boolean false)" {
    run jsonrpc_init_json "false"
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_init_json: should fail with invalid ID (array)" {
    run jsonrpc_init_json '["test"]'
    [ "${status}" -eq 1 ]
}

@test "jsonrpc_init_json: should fail with invalid ID (object)" {
    run jsonrpc_init_json '{"test": "value"}'
    [ "${status}" -eq 1 ]
}
