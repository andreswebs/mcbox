#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "is_valid_json: valid JSON object should return 0" {
    run is_valid_json '{"name": "John", "age": 30}'
    assert_success
}

@test "is_valid_json: valid JSON array should return 0" {
    run is_valid_json '["apple", "banana", "cherry"]'
    assert_success
}

@test "is_valid_json: valid JSON string should return 0" {
    run is_valid_json '"hello world"'
    assert_success
}

@test "is_valid_json: valid JSON number should return 0" {
    run is_valid_json '42'
    assert_success
}

@test "is_valid_json: valid JSON boolean true should return 0" {
    run is_valid_json 'true'
    assert_success
}

@test "is_valid_json: valid JSON boolean false should return 0" {
    run is_valid_json 'false'
    assert_success
}

@test "is_valid_json: valid JSON null should return 0" {
    run is_valid_json 'null'
    assert_success
}

@test "is_valid_json: valid nested JSON object should return 0" {
    run is_valid_json '{"user": {"name": "John", "details": {"age": 30, "active": true}}}'
    assert_success
}

@test "is_valid_json: valid JSON with whitespace should return 0" {
    run is_valid_json '  {  "name"  :  "John"  }  '
    assert_success
}

@test "is_valid_json: invalid JSON object with missing quotes should return 1" {
    run is_valid_json '{name: "John"}'
    assert_failure
}

@test "is_valid_json: invalid JSON with trailing comma should return 1" {
    run is_valid_json '{"name": "John",}'
    assert_failure
}

@test "is_valid_json: invalid JSON with unmatched braces should return 1" {
    run is_valid_json '{"name": "John"'
    assert_failure
}

@test "is_valid_json: invalid JSON with unmatched brackets should return 1" {
    run is_valid_json '["apple", "banana"'
    assert_failure
}

@test "is_valid_json: plain string without quotes should return 1" {
    run is_valid_json 'hello world'
    assert_failure
}

@test "is_valid_json: empty string should return 1" {
    run is_valid_json ''
    assert_failure
}

@test "is_valid_json: invalid JSON with single quotes should return 1" {
    run is_valid_json "{'name': 'John'}"
    assert_failure
}

@test "is_valid_json: invalid JSON with undefined should return 1" {
    run is_valid_json '{"name": undefined}'
    assert_failure
}

@test "is_valid_json: invalid JSON with NaN should return 1" {
    run is_valid_json '{"value": NaN}'
    assert_failure
}

@test "is_valid_json: invalid JSON with Infinity should return 1" {
    run is_valid_json '{"value": Infinity}'
    assert_failure
}

@test "is_valid_json: plain number without proper JSON context should return 0" {
    # This is actually valid JSON - a plain number
    run is_valid_json '123'
    assert_success
}

@test "is_valid_json: multiple JSON objects without array wrapper should return 1" {
    run is_valid_json '{"a": 1} {"b": 2}'
    assert_failure
}

@test "is_valid_json: JSON with comments should return 1" {
    run is_valid_json '{"name": "John" /* comment */}'
    assert_failure
}

@test "is_valid_json: handles special characters in strings" {
    run is_valid_json '{"message": "Hello\nWorld\t!"}'
    assert_success
}

@test "is_valid_json: handles unicode characters" {
    run is_valid_json '{"emoji": "🚀", "unicode": "café"}'
    assert_success
}
