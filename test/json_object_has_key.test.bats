#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

@test "json_object_has_key: object with existing key should return 0" {
    run json_object_has_key '{"name": "John", "age": 30}' "name"
    assert_success
}

@test "json_object_has_key: object with existing nested key should return 0" {
    run json_object_has_key '{"user": {"name": "John", "age": 30}, "active": true}' "user"
    assert_success
}

@test "json_object_has_key: object with non-existing key should return 1" {
    run json_object_has_key '{"name": "John", "age": 30}' "email"
    assert_failure
}

@test "json_object_has_key: empty object with any key should return 1" {
    run json_object_has_key '{}' "name"
    assert_failure
}

@test "json_object_has_key: object with numeric key should work" {
    run json_object_has_key '{"1": "one", "2": "two"}' "1"
    assert_success
}

@test "json_object_has_key: object with special characters in key should work" {
    run json_object_has_key '{"user@domain.com": "email", "first-name": "John"}' "user@domain.com"
    assert_success
}

@test "json_object_has_key: object with special characters in key should work for hyphenated key" {
    run json_object_has_key '{"user@domain.com": "email", "first-name": "John"}' "first-name"
    assert_success
}

@test "json_object_has_key: object with spaces in key should work" {
    run json_object_has_key '{"full name": "John Doe", "age": 30}' "full name"
    assert_success
}

@test "json_object_has_key: object with boolean values should work" {
    run json_object_has_key '{"active": true, "verified": false}' "active"
    assert_success
}

@test "json_object_has_key: object with null values should work" {
    run json_object_has_key '{"name": "John", "middle_name": null}' "middle_name"
    assert_success
}

@test "json_object_has_key: object with array values should work" {
    run json_object_has_key '{"tags": ["red", "blue"], "count": 2}' "tags"
    assert_success
}

@test "json_object_has_key: object with object values should work" {
    run json_object_has_key '{"user": {"name": "John"}, "count": 1}' "user"
    assert_success
}

@test "json_object_has_key: invalid JSON should return 1" {
    run json_object_has_key '{"name": "John", "age":}' "name"
    assert_failure
}

@test "json_object_has_key: JSON array should return 1" {
    run json_object_has_key '["apple", "banana"]' "0"
    assert_failure
}

@test "json_object_has_key: JSON string should return 1" {
    run json_object_has_key '"hello world"' "length"
    assert_failure
}

@test "json_object_has_key: JSON number should return 1" {
    run json_object_has_key '42' "toString"
    assert_failure
}

@test "json_object_has_key: JSON boolean should return 1" {
    run json_object_has_key 'true' "valueOf"
    assert_failure
}

@test "json_object_has_key: JSON null should return 1" {
    run json_object_has_key 'null' "toString"
    assert_failure
}

@test "json_object_has_key: empty string input should return 1" {
    run json_object_has_key '' "name"
    assert_failure
}

@test "json_object_has_key: empty key should work if object has empty key" {
    run json_object_has_key '{"": "empty_key_value", "name": "John"}' ""
    assert_success
}

@test "json_object_has_key: empty key should fail if object doesn't have empty key" {
    run json_object_has_key '{"name": "John", "age": 30}' ""
    assert_failure
}

@test "json_object_has_key: case sensitive key matching" {
    run json_object_has_key '{"Name": "John", "age": 30}' "name"
    assert_failure
}

@test "json_object_has_key: case sensitive key matching should work for exact match" {
    run json_object_has_key '{"Name": "John", "age": 30}' "Name"
    assert_success
}

@test "json_object_has_key: complex nested object structure" {
    run json_object_has_key '{"user": {"profile": {"name": "John", "settings": {"theme": "dark"}}}, "meta": {"created": "2023-01-01"}}' "user"
    assert_success
}

@test "json_object_has_key: complex nested object structure - non-existing top-level key" {
    run json_object_has_key '{"user": {"profile": {"name": "John", "settings": {"theme": "dark"}}}, "meta": {"created": "2023-01-01"}}' "admin"
    assert_failure
}

@test "json_object_has_key: object with unicode characters in key" {
    run json_object_has_key '{"名前": "田中", "age": 30}' "名前"
    assert_success
}

@test "json_object_has_key: object with escaped quotes in key" {
    run json_object_has_key '{"say \"hello\"": "world", "normal": "key"}' "say \"hello\""
    assert_success
}
