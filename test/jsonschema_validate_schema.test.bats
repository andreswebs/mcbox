#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "jsonschema_validate_schema: valid arguments" {
    local tool_schema='{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}, "required": ["name"]}'
    local valid_args='{"name": "John", "age": 30}'

    run jsonschema_validate_schema "${valid_args}" "${tool_schema}"
    assert_success
}

@test "jsonschema_validate_schema: missing required argument" {
    local tool_schema='{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}, "required": ["name"]}'
    local missing_required_args='{"age": 30}'

    run jsonschema_validate_schema "${missing_required_args}" "${tool_schema}"
    assert_failure
}

@test "jsonschema_validate_schema: unknown argument" {
    local tool_schema='{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}, "required": ["name"]}'
    local unknown_args='{"name": "John", "unknown": "value"}'

    run jsonschema_validate_schema "${unknown_args}" "${tool_schema}"
    assert_failure
}

@test "jsonschema_validate_schema: invalid argument type" {
    local tool_schema='{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}, "required": ["name"]}'
    local invalid_type_args='{"name": "John", "age": "not a number"}'

    run jsonschema_validate_schema "${invalid_type_args}" "${tool_schema}"
    assert_failure
}

@test "jsonschema_validate_schema: complex arguments with all types" {
    local complex_schema='{"type": "object", "properties": {"name": {"type": "string"}, "count": {"type": "integer"}, "price": {"type": "number"}, "active": {"type": "boolean"}, "tags": {"type": "array"}, "config": {"type": "object"}}, "required": ["name", "count"]}'
    local complex_args='{"name": "Product", "count": 5, "price": 19.99, "active": true, "tags": ["new", "sale"], "config": {"key": "value"}}'

    run jsonschema_validate_schema "${complex_args}" "${complex_schema}"
    assert_success
}

@test "jsonschema_validate_schema: empty schema" {
    local no_schema=""
    local any_args='{"param": "value"}'

    run jsonschema_validate_schema "${any_args}" "${no_schema}"
    assert_failure
}

@test "jsonschema_validate_schema: invalid schema format" {
    local tool_schema='"invalid schema"'
    local valid_args='{"name": "John", "age": 30}'

    run jsonschema_validate_schema "${valid_args}" "${tool_schema}"
    assert_failure
}

@test "jsonschema_validate_schema: invalid arguments format" {
    local tool_schema='{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "integer"}}, "required": ["name"]}'
    local invalid_args='"invalid args"'

    run jsonschema_validate_schema "${invalid_args}" "${tool_schema}"
    assert_failure
}
