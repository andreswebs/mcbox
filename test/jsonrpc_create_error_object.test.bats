#!/usr/bin/env bats
# shellcheck shell=bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "jsonrpc_create_error_object: should create error object with integer code and message" {
    local expected='{"error":{"code":-32601,"message":"Method not found"}}'

    run jsonrpc_create_error_object "-32601" "Method not found"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with positive code" {
    local expected='{"error":{"code":1001,"message":"Custom error"}}'

    run jsonrpc_create_error_object "1001" "Custom error"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with zero code" {
    local expected='{"error":{"code":0,"message":"No error"}}'

    run jsonrpc_create_error_object "0" "No error"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should handle message with special characters" {
    local expected='{"error":{"code":-32700,"message":"Parse error: unexpected \"character\""}}'

    run jsonrpc_create_error_object "-32700" "Parse error: unexpected \"character\""
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should handle empty message" {
    local expected='{"error":{"code":-32600,"message":""}}'

    run jsonrpc_create_error_object "-32600" ""
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should handle message with newlines" {
    local expected='{"error":{"code":-32603,"message":"Internal error\\nMultiple lines"}}'

    run jsonrpc_create_error_object "-32603" "Internal error\nMultiple lines"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should handle JSON-RPC standard error codes" {
    local expected='{"error":{"code":-32602,"message":"Invalid params"}}'

    run jsonrpc_create_error_object "-32602" "Invalid params"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should fail with no arguments" {
    run jsonrpc_create_error_object
    assert_failure
    assert_line --partial "requires two arguments"
}

@test "jsonrpc_create_error_object: should fail with only one argument" {
    run jsonrpc_create_error_object "-32601"
    assert_failure
    assert_line --partial "requires two arguments"
}

@test "jsonrpc_create_error_object: should fail with non-numeric error code" {
    run jsonrpc_create_error_object "invalid" "Some message"
    assert_failure
    assert_line --partial "the error code must be an integer"
}

@test "jsonrpc_create_error_object: should fail with fractional error code" {
    run jsonrpc_create_error_object "123.45" "Some message"
    assert_failure
    assert_line --partial "the error code must be an integer"
}

@test "jsonrpc_create_error_object: should produce valid JSON output" {
    run jsonrpc_create_error_object "-32000" "Server error"
    assert_success

    # Validate that output is valid JSON by parsing it with jq
    run bash -c "echo '${output}' | jq -e '.error.code == -32000 and .error.message == \"Server error\"'"
    assert_success
}

@test "jsonrpc_create_error_object: should handle large error codes" {
    local expected='{"error":{"code":-2147483648,"message":"Large negative code"}}'

    run jsonrpc_create_error_object "-2147483648" "Large negative code"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should handle unicode characters in message" {
    local expected='{"error":{"code":-32000,"message":"Unicode: 🚨 error"}}'

    run jsonrpc_create_error_object "-32000" "Unicode: 🚨 error"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with string data" {
    local expected='{"error":{"code":-32000,"message":"Server error","data":"Additional error information"}}'

    run jsonrpc_create_error_object "-32000" "Server error" "Additional error information"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with JSON object data" {
    local expected='{"error":{"code":-32602,"message":"Invalid params","data":{"field":"username","reason":"required"}}}'

    run jsonrpc_create_error_object "-32602" "Invalid params" '{"field":"username","reason":"required"}'
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with JSON array data" {
    local expected='{"error":{"code":-32603,"message":"Internal error","data":["error1","error2","error3"]}}'

    run jsonrpc_create_error_object "-32603" "Internal error" '["error1","error2","error3"]'
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with numeric data" {
    local expected='{"error":{"code":-32001,"message":"Custom error","data":42}}'

    run jsonrpc_create_error_object "-32001" "Custom error" "42"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with boolean data" {
    local expected='{"error":{"code":-32002,"message":"Validation failed","data":true}}'

    run jsonrpc_create_error_object "-32002" "Validation failed" "true"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with null data" {
    local expected='{"error":{"code":-32003,"message":"Null data","data":null}}'

    run jsonrpc_create_error_object "-32003" "Null data" "null"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with empty string data" {
    local expected='{"error":{"code":-32004,"message":"Empty data"}}'

    run jsonrpc_create_error_object "-32004" "Empty data" ""
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should create error object with complex nested JSON data" {
    local data='{"error_details":{"stack_trace":["function1","function2"],"timestamp":"2023-10-08T10:00:00Z"},"user_context":{"id":123,"name":"test"}}'
    local expected='{"error":{"code":-32005,"message":"Complex error","data":{"error_details":{"stack_trace":["function1","function2"],"timestamp":"2023-10-08T10:00:00Z"},"user_context":{"id":123,"name":"test"}}}}'

    run jsonrpc_create_error_object "-32005" "Complex error" "${data}"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_object: should handle data with special characters and escaping" {
    local expected='{"error":{"code":-32006,"message":"Escape test","data":"Data with \"quotes\" and \\backslashes\\"}}'

    # shellcheck disable=SC1003
    run jsonrpc_create_error_object "-32006" "Escape test" 'Data with "quotes" and \backslashes\'
    assert_success
    assert_output "${expected}"
}
