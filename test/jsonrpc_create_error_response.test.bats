#!/usr/bin/env bats
# shellcheck shell=bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "jsonrpc_create_error_response: should require at least three arguments" {
    run jsonrpc_create_error_response
    assert_failure
    assert_output --partial "requires at least three arguments"
}

@test "jsonrpc_create_error_response: should require at least three when only id provided" {
    run jsonrpc_create_error_response "123"
    assert_failure
    assert_output --partial "requires at least three arguments"
}

@test "jsonrpc_create_error_response: should require at least three when only id and error code provided" {
    run jsonrpc_create_error_response "123" "-32601"
    assert_failure
    assert_output --partial "requires at least three arguments"
}

@test "jsonrpc_create_error_response: should create error response with string id" {
    local expected='{"jsonrpc":"2.0","id":"test-id","error":{"code":-32601,"message":"Method not found"}}'

    run jsonrpc_create_error_response "test-id" "-32601" "Method not found"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with numeric id" {
    local expected='{"jsonrpc":"2.0","id":123,"error":{"code":-32700,"message":"Parse error"}}'

    run jsonrpc_create_error_response "123" "-32700" "Parse error"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with null id" {
    local expected='{"jsonrpc":"2.0","id":null,"error":{"code":-32600,"message":"Invalid Request"}}'

    run jsonrpc_create_error_response "null" "-32600" "Invalid Request"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with JSON-formatted string id" {
    local expected='{"jsonrpc":"2.0","id":"my-request-id","error":{"code":-32603,"message":"Internal error"}}'

    run jsonrpc_create_error_response '"my-request-id"' "-32603" "Internal error"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should handle positive error codes" {
    local expected='{"jsonrpc":"2.0","id":456,"error":{"code":1001,"message":"Custom application error"}}'

    run jsonrpc_create_error_response "456" "1001" "Custom application error"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should handle zero error code" {
    local expected='{"jsonrpc":"2.0","id":"zero-error","error":{"code":0,"message":"No error condition"}}'

    run jsonrpc_create_error_response "zero-error" "0" "No error condition"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should handle empty error message" {
    local expected='{"jsonrpc":"2.0","id":789,"error":{"code":-32602,"message":""}}'

    run jsonrpc_create_error_response "789" "-32602" ""
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should handle error message with special characters" {
    local expected='{"jsonrpc":"2.0","id":"special-chars","error":{"code":-32700,"message":"Parse error: unexpected \"character\""}}'

    run jsonrpc_create_error_response "special-chars" "-32700" "Parse error: unexpected \"character\""
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should handle error message with newlines" {
    local expected='{"jsonrpc":"2.0","id":"multiline","error":{"code":-32603,"message":"Internal error\\nMultiple lines"}}'

    run jsonrpc_create_error_response "multiline" "-32603" "Internal error\nMultiple lines"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should handle error message with unicode characters" {
    local expected='{"jsonrpc":"2.0","id":"unicode","error":{"code":-32000,"message":"Erreur avec caractères spéciaux: éàü"}}'

    run jsonrpc_create_error_response "unicode" "-32000" "Erreur avec caractères spéciaux: éàü"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should fail with non-integer error code" {
    run jsonrpc_create_error_response "test-id" "not-a-number" "Invalid error code"
    assert_failure
    assert_output --partial "the error code must be an integer"
}

@test "jsonrpc_create_error_response: should fail with floating point error code" {
    run jsonrpc_create_error_response "test-id" "-32601.5" "Floating point error code"
    assert_failure
    assert_output --partial "the error code must be an integer"
}

@test "jsonrpc_create_error_response: should handle standard JSON-RPC error codes" {
    # Test parse error
    run jsonrpc_create_error_response "1" "-32700" "Parse error"
    assert_success
    assert_output '{"jsonrpc":"2.0","id":1,"error":{"code":-32700,"message":"Parse error"}}'

    # Test invalid request
    run jsonrpc_create_error_response "2" "-32600" "Invalid Request"
    assert_success
    assert_output '{"jsonrpc":"2.0","id":2,"error":{"code":-32600,"message":"Invalid Request"}}'

    # Test method not found
    run jsonrpc_create_error_response "3" "-32601" "Method not found"
    assert_success
    assert_output '{"jsonrpc":"2.0","id":3,"error":{"code":-32601,"message":"Method not found"}}'

    # Test invalid params
    run jsonrpc_create_error_response "4" "-32602" "Invalid params"
    assert_success
    assert_output '{"jsonrpc":"2.0","id":4,"error":{"code":-32602,"message":"Invalid params"}}'

    # Test internal error
    run jsonrpc_create_error_response "5" "-32603" "Internal error"
    assert_success
    assert_output '{"jsonrpc":"2.0","id":5,"error":{"code":-32603,"message":"Internal error"}}'
}

@test "jsonrpc_create_error_response: should handle large numeric id" {
    local expected='{"jsonrpc":"2.0","id":9007199254740991,"error":{"code":-32000,"message":"Server error"}}'

    run jsonrpc_create_error_response "9007199254740991" "-32000" "Server error"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should fail with negative numeric id" {
    run jsonrpc_create_error_response "-123" "-32001" "Server error"
    assert_failure
    assert_output --partial "invalid id: -123"
}

@test "jsonrpc_create_error_response: should create error response with string data" {
    local expected='{"jsonrpc":"2.0","id":"test-id","error":{"code":-32000,"message":"Server error","data":"Additional error information"}}'

    run jsonrpc_create_error_response "test-id" "-32000" "Server error" "Additional error information"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with JSON object data" {
    local expected='{"jsonrpc":"2.0","id":123,"error":{"code":-32602,"message":"Invalid params","data":{"field":"username","reason":"required"}}}'

    run jsonrpc_create_error_response "123" "-32602" "Invalid params" '{"field":"username","reason":"required"}'
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with JSON array data" {
    local expected='{"jsonrpc":"2.0","id":"error-123","error":{"code":-32603,"message":"Internal error","data":["error1","error2","error3"]}}'

    run jsonrpc_create_error_response "error-123" "-32603" "Internal error" '["error1","error2","error3"]'
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with numeric data" {
    local expected='{"jsonrpc":"2.0","id":null,"error":{"code":-32001,"message":"Custom error","data":42}}'

    run jsonrpc_create_error_response "null" "-32001" "Custom error" "42"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with boolean data" {
    local expected='{"jsonrpc":"2.0","id":"req-456","error":{"code":-32002,"message":"Validation failed","data":true}}'

    run jsonrpc_create_error_response "req-456" "-32002" "Validation failed" "true"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with null data" {
    local expected='{"jsonrpc":"2.0","id":789,"error":{"code":-32003,"message":"Null data","data":null}}'

    run jsonrpc_create_error_response "789" "-32003" "Null data" "null"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with empty string data ignored" {
    local expected='{"jsonrpc":"2.0","id":"empty-test","error":{"code":-32004,"message":"Empty data"}}'

    run jsonrpc_create_error_response "empty-test" "-32004" "Empty data" ""
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should create error response with complex nested JSON data" {
    local data='{"error_details":{"stack_trace":["function1","function2"],"timestamp":"2023-10-08T10:00:00Z"},"user_context":{"id":123,"name":"test"}}'
    local expected='{"jsonrpc":"2.0","id":"complex-error","error":{"code":-32005,"message":"Complex error","data":{"error_details":{"stack_trace":["function1","function2"],"timestamp":"2023-10-08T10:00:00Z"},"user_context":{"id":123,"name":"test"}}}}'

    run jsonrpc_create_error_response "complex-error" "-32005" "Complex error" "${data}"
    assert_success
    assert_output "${expected}"
}

@test "jsonrpc_create_error_response: should handle data with special characters and escaping" {
    local expected='{"jsonrpc":"2.0","id":"escape-test","error":{"code":-32006,"message":"Escape test","data":"Data with \"quotes\" and \\backslashes\\"}}'

    run jsonrpc_create_error_response "escape-test" "-32006" "Escape test" 'Data with "quotes" and \backslashes\'
    assert_success
    assert_output "${expected}"
}
