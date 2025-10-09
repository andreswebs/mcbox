#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "jsonrpc_create_result_response: should require two arguments" {
    run jsonrpc_create_result_response
    assert_failure
    assert_output --partial "requires two arguments"
}

@test "jsonrpc_create_result_response: should require two arguments when only id provided" {
    run jsonrpc_create_result_response "123"
    assert_failure
    assert_output --partial "requires two arguments"
}

@test "jsonrpc_create_result_response: should accept simple strings as result" {
    run jsonrpc_create_result_response "123" "invalid json"
    assert_success
    assert_output '{"jsonrpc":"2.0","id":123,"result":"invalid json"}'
}

@test "jsonrpc_create_result_response: should create result response with string id and string result" {
    run jsonrpc_create_result_response "test-id" '"hello world"'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":"test-id","result":"hello world"}'
}

@test "jsonrpc_create_result_response: should create result response with numeric id and object result" {
    run jsonrpc_create_result_response "123" '{"key":"value","number":42}'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":123,"result":{"key":"value","number":42}}'
}

@test "jsonrpc_create_result_response: should create result response with null id and array result" {
    run jsonrpc_create_result_response "null" '[1,2,3]'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":null,"result":[1,2,3]}'
}

@test "jsonrpc_create_result_response: should create result response with JSON-formatted string id" {
    run jsonrpc_create_result_response '"my-request-id"' 'true'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":"my-request-id","result":true}'
}

@test "jsonrpc_create_result_response: should create result response with boolean result" {
    run jsonrpc_create_result_response "456" 'false'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":456,"result":false}'
}

@test "jsonrpc_create_result_response: should create result response with null result" {
    run jsonrpc_create_result_response "789" 'null'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":789,"result":null}'
}

@test "jsonrpc_create_result_response: should create result response with numeric result" {
    run jsonrpc_create_result_response "test" '42.5'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":"test","result":42.5}'
}

@test "jsonrpc_create_result_response: should handle empty object result" {
    run jsonrpc_create_result_response "empty" '{}'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":"empty","result":{}}'
}

@test "jsonrpc_create_result_response: should handle empty array result" {
    run jsonrpc_create_result_response "empty-array" '[]'
    assert_success
    assert_output '{"jsonrpc":"2.0","id":"empty-array","result":[]}'
}

@test "jsonrpc_create_result_response: should accept malformed JSON as string result" {
    run jsonrpc_create_result_response "test" '{"key": value}'
    assert_failure
    assert_output --partial "malformed JSON"
}

@test "jsonrpc_create_result_response: should accept incomplete JSON as string result" {
    run jsonrpc_create_result_response "test" '{"key":'
    assert_failure
    assert_output --partial "malformed JSON"
}

@test "jsonrpc_create_result_response: should reject empty string as result" {
    run jsonrpc_create_result_response "test" ''
    assert_failure
    assert_output --partial "result cannot be empty"
}
