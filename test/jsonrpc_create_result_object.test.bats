#!/usr/bin/env bats

load '../mcbox-core.bash'

load "bats-helpers/bats-support/load"
load "bats-helpers/bats-assert/load"

# Test successful cases

@test "jsonrpc_create_result_object: creates result object with valid JSON string" {
    run jsonrpc_create_result_object '"hello world"'
    assert_success
    assert_output '{"result":"hello world"}'
}

@test "jsonrpc_create_result_object: creates result object with valid JSON number" {
    run jsonrpc_create_result_object '42'
    assert_success
    assert_output '{"result":42}'
}

@test "jsonrpc_create_result_object: creates result object with valid JSON boolean true" {
    run jsonrpc_create_result_object 'true'
    assert_success
    assert_output '{"result":true}'
}

@test "jsonrpc_create_result_object: creates result object with valid JSON boolean false" {
    run jsonrpc_create_result_object 'false'
    assert_success
    assert_output '{"result":false}'
}

@test "jsonrpc_create_result_object: creates result object with valid JSON null" {
    run jsonrpc_create_result_object 'null'
    assert_success
    assert_output '{"result":null}'
}

@test "jsonrpc_create_result_object: creates result object with valid JSON array" {
    run jsonrpc_create_result_object '[1,2,3]'
    assert_success
    assert_output '{"result":[1,2,3]}'
}

@test "jsonrpc_create_result_object: creates result object with valid JSON object" {
    run jsonrpc_create_result_object '{"key":"value"}'
    assert_success
    assert_output '{"result":{"key":"value"}}'
}

@test "jsonrpc_create_result_object: creates result object with complex nested JSON" {
    run jsonrpc_create_result_object '{"users":[{"id":1,"name":"John"},{"id":2,"name":"Jane"}],"total":2}'
    assert_success
    assert_output '{"result":{"users":[{"id":1,"name":"John"},{"id":2,"name":"Jane"}],"total":2}}'
}

@test "jsonrpc_create_result_object: creates result object with plain string (non-JSON)" {
    run jsonrpc_create_result_object 'hello'
    assert_success
    assert_output '{"result":"hello"}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing spaces" {
    run jsonrpc_create_result_object 'hello world'
    assert_success
    assert_output '{"result":"hello world"}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing special characters" {
    run jsonrpc_create_result_object 'hello@world.com'
    assert_success
    assert_output '{"result":"hello@world.com"}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing quotes" {
    run jsonrpc_create_result_object "hello 'world'"
    assert_success
    assert_output '{"result":"hello '\''world'\''"}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing double quotes" {
    run jsonrpc_create_result_object 'hello "world"'
    assert_success
    assert_output '{"result":"hello \"world\""}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing backslashes" {
    run jsonrpc_create_result_object 'hello\world'
    assert_success
    assert_output '{"result":"hello\\world"}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing newlines" {
    run jsonrpc_create_result_object $'hello\nworld'
    assert_success
    assert_output $'{"result":"hello\\nworld"}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing tabs" {
    run jsonrpc_create_result_object $'hello\tworld'
    assert_success
    assert_output '{"result":"hello\tworld"}'
}

@test "jsonrpc_create_result_object: creates result object with zero" {
    run jsonrpc_create_result_object '0'
    assert_success
    assert_output '{"result":0}'
}

@test "jsonrpc_create_result_object: creates result object with negative number" {
    run jsonrpc_create_result_object '-42'
    assert_success
    assert_output '{"result":-42}'
}

@test "jsonrpc_create_result_object: creates result object with floating point number" {
    run jsonrpc_create_result_object '3.14'
    assert_success
    assert_output '{"result":3.14}'
}

@test "jsonrpc_create_result_object: creates result object with scientific notation" {
    run jsonrpc_create_result_object '1.23e10'
    assert_success
    assert_output '{"result":1.23E+10}'
}

@test "jsonrpc_create_result_object: creates result object with empty JSON array" {
    run jsonrpc_create_result_object '[]'
    assert_success
    assert_output '{"result":[]}'
}

@test "jsonrpc_create_result_object: creates result object with empty JSON object" {
    run jsonrpc_create_result_object '{}'
    assert_success
    assert_output '{"result":{}}'
}

@test "jsonrpc_create_result_object: creates result object with JSON string containing escape sequences" {
    run jsonrpc_create_result_object '"hello\nworld\t\""'
    assert_success
    assert_output '{"result":"hello\nworld\t\""}'
}

@test "jsonrpc_create_result_object: creates result object with unicode characters in JSON string" {
    run jsonrpc_create_result_object '"hello 世界"'
    assert_success
    assert_output '{"result":"hello 世界"}'
}

@test "jsonrpc_create_result_object: creates result object with unicode characters in plain string" {
    run jsonrpc_create_result_object 'hello 世界'
    assert_success
    assert_output '{"result":"hello 世界"}'
}

@test "jsonrpc_create_result_object: creates result object with multiple internal JSON values" {
    run jsonrpc_create_result_object '"hello" "world"'
    assert_success
    assert_output '{"result":"\"hello\" \"world\""}'
}

@test "jsonrpc_create_result_object: creates result object with NaN as plain string" {
    run jsonrpc_create_result_object 'NaN'
    assert_success
    assert_output '{"result":"NaN"}'
}

@test "jsonrpc_create_result_object: creates result object with Infinity as plain string" {
    run jsonrpc_create_result_object 'Infinity'
    assert_success
    assert_output '{"result":"Infinity"}'
}

@test "jsonrpc_create_result_object: creates result object with -Infinity as plain string" {
    run jsonrpc_create_result_object '-Infinity'
    assert_success
    assert_output '{"result":"-Infinity"}'
}

# Test error cases

@test "jsonrpc_create_result_object: fails when no arguments provided" {
    run jsonrpc_create_result_object
    assert_failure
    assert_line --partial "requires an argument"
}

@test "jsonrpc_create_result_object: fails when result is empty string" {
    run jsonrpc_create_result_object ''
    assert_failure
    assert_line --partial "result cannot be empty"
}

@test "jsonrpc_create_result_object: fails with malformed JSON string" {
    run jsonrpc_create_result_object '"unterminated string'
    assert_failure
}

@test "jsonrpc_create_result_object: fails with malformed JSON object" {
    run jsonrpc_create_result_object '{"key": value}'
    assert_failure
}

@test "jsonrpc_create_result_object: fails with trailing comma in JSON object" {
    run jsonrpc_create_result_object '{"key":"value",}'
    assert_failure
}

@test "jsonrpc_create_result_object: fails with malformed JSON array" {
    run jsonrpc_create_result_object '[1,2,3'
    assert_failure
}

@test "jsonrpc_create_result_object: fails with trailing comma in JSON array" {
    run jsonrpc_create_result_object '[1,2,3,]'
    assert_failure
}

@test "jsonrpc_create_result_object: fails with invalid escape sequence in JSON string" {
    run jsonrpc_create_result_object '"\x"'
    assert_failure
}

@test "jsonrpc_create_result_object: fails with single quotes instead of double quotes" {
    run jsonrpc_create_result_object "{'key': 'value'}"
    assert_failure
}

@test "jsonrpc_create_result_object: fails with unquoted keys in JSON object" {
    run jsonrpc_create_result_object '{key: "value"}'
    assert_failure
}

# Edge cases with whitespace

@test "jsonrpc_create_result_object: creates result object with JSON containing leading/trailing whitespace" {
    run jsonrpc_create_result_object '  {"key":"value"}  '
    assert_success
    assert_output '{"result":{"key":"value"}}'
}

@test "jsonrpc_create_result_object: creates result object with plain string containing only whitespace" {
    run jsonrpc_create_result_object '   '
    assert_success
    assert_output '{"result":"   "}'
}

# Edge cases with very large values

@test "jsonrpc_create_result_object: creates result object with very large number" {
    run jsonrpc_create_result_object '9223372036854775807'
    assert_success
    assert_output '{"result":9223372036854775807}'
}

@test "jsonrpc_create_result_object: creates result object with very long string" {
    local long_string
    long_string=$(printf 'a%.0s' {1..1000})
    run jsonrpc_create_result_object "${long_string}"
    assert_success
    assert_output "{\"result\":\"${long_string}\"}"
}

# Edge cases with special JSON values

@test "jsonrpc_create_result_object: creates result object with JSON empty string" {
    run jsonrpc_create_result_object '""'
    assert_success
    assert_output '{"result":""}'
}

@test "jsonrpc_create_result_object: creates result object with JSON string containing only numbers" {
    run jsonrpc_create_result_object '"123"'
    assert_success
    assert_output '{"result":"123"}'
}

@test "jsonrpc_create_result_object: creates result object with JSON string that looks like boolean" {
    run jsonrpc_create_result_object '"true"'
    assert_success
    assert_output '{"result":"true"}'
}

@test "jsonrpc_create_result_object: creates result object with JSON string that looks like null" {
    run jsonrpc_create_result_object '"null"'
    assert_success
    assert_output '{"result":"null"}'
}
