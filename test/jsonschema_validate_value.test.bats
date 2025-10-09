#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "jsonschema_validate_value: valid string should return 0" {
    run jsonschema_validate_value '"hello"' '{"type": "string"}'
    assert_success
}

@test "jsonschema_validate_value: invalid string (number) should return 1" {
    run jsonschema_validate_value '123' '{"type": "string"}'
    assert_failure
}

@test "jsonschema_validate_value: valid number should return 0" {
    run jsonschema_validate_value '123.45' '{"type": "number"}'
    assert_success
}

@test "jsonschema_validate_value: invalid number (string) should return 1" {
    run jsonschema_validate_value '"not a number"' '{"type": "number"}'
    assert_failure
}

@test "jsonschema_validate_value: valid integer should return 0" {
    run jsonschema_validate_value '42' '{"type": "integer"}'
    assert_success
}

@test "jsonschema_validate_value: invalid integer (decimal) should return 1" {
    run jsonschema_validate_value '42.5' '{"type": "integer"}'
    assert_failure
}

@test "jsonschema_validate_value: invalid integer (string) should return 1" {
    run jsonschema_validate_value '"42"' '{"type": "integer"}'
    assert_failure
}

@test "jsonschema_validate_value: valid boolean true should return 0" {
    run jsonschema_validate_value 'true' '{"type": "boolean"}'
    assert_success
}

@test "jsonschema_validate_value: valid boolean false should return 0" {
    run jsonschema_validate_value 'false' '{"type": "boolean"}'
    assert_success
}

@test "jsonschema_validate_value: invalid boolean (number) should return 1" {
    run jsonschema_validate_value '1' '{"type": "boolean"}'
    assert_failure
}

@test "jsonschema_validate_value: invalid boolean (string) should return 1" {
    run jsonschema_validate_value '"true"' '{"type": "boolean"}'
    assert_failure
}

@test "jsonschema_validate_value: valid array should return 0" {
    run jsonschema_validate_value '[1, 2, 3]' '{"type": "array"}'
    assert_success
}

@test "jsonschema_validate_value: valid empty array should return 0" {
    run jsonschema_validate_value '[]' '{"type": "array"}'
    assert_success
}

@test "jsonschema_validate_value: invalid array (object) should return 1" {
    run jsonschema_validate_value '{}' '{"type": "array"}'
    assert_failure
}

@test "jsonschema_validate_value: invalid array (string) should return 1" {
    run jsonschema_validate_value '"[1,2,3]"' '{"type": "array"}'
    assert_failure
}

@test "jsonschema_validate_value: valid object should return 0" {
    run jsonschema_validate_value '{"key": "value"}' '{"type": "object"}'
    assert_success
}

@test "jsonschema_validate_value: valid empty object should return 0" {
    run jsonschema_validate_value '{}' '{"type": "object"}'
    assert_success
}

@test "jsonschema_validate_value: invalid object (array) should return 1" {
    run jsonschema_validate_value '[]' '{"type": "object"}'
    assert_failure
}

@test "jsonschema_validate_value: invalid object (string) should return 1" {
    run jsonschema_validate_value '"{\"key\":\"value\"}"' '{"type": "object"}'
    assert_failure
}

@test "jsonschema_validate_value: invalid schema format (not object) should return 1" {
    run jsonschema_validate_value '"test"' '"invalid schema"'
    assert_failure
}

@test "jsonschema_validate_value: invalid schema format (array) should return 1" {
    run jsonschema_validate_value '"test"' '["invalid", "schema"]'
    assert_failure
}

@test "jsonschema_validate_value: schema missing type should return 1" {
    run jsonschema_validate_value '"test"' '{"no_type": "string"}'
    assert_failure
}

@test "jsonschema_validate_value: schema with empty type should return 1" {
    run jsonschema_validate_value '"test"' '{"type": ""}'
    assert_failure
}

@test "jsonschema_validate_value: unsupported schema type should return 1" {
    run jsonschema_validate_value '"test"' '{"type": "unknown"}'
    assert_failure
}

@test "jsonschema_validate_value: complex valid number (negative) should return 0" {
    run jsonschema_validate_value '-123.45' '{"type": "number"}'
    assert_success
}

@test "jsonschema_validate_value: complex valid integer (negative) should return 0" {
    run jsonschema_validate_value '-42' '{"type": "integer"}'
    assert_success
}

@test "jsonschema_validate_value: complex valid integer (zero) should return 0" {
    run jsonschema_validate_value '0' '{"type": "integer"}'
    assert_success
}

@test "jsonschema_validate_value: nested array should return 0" {
    run jsonschema_validate_value '[[1, 2], [3, 4]]' '{"type": "array"}'
    assert_success
}

@test "jsonschema_validate_value: nested object should return 0" {
    run jsonschema_validate_value '{"outer": {"inner": "value"}}' '{"type": "object"}'
    assert_success
}
