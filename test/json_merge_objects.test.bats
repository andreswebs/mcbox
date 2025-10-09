#!/usr/bin/env bats
# shellcheck shell=bats

load '../mcbox-core.bash'

@test "json_merge_objects: should fail with no arguments" {
    run json_merge_objects
    [ "${status}" -eq 1 ]
}

@test "json_merge_objects: should merge two simple objects" {
    local json1='{"name": "John", "age": 30}'
    local json2='{"city": "New York", "country": "USA"}'
    local expected='{"name":"John","age":30,"city":"New York","country":"USA"}'

    run json_merge_objects "${json1}" "${json2}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_merge_objects: should merge objects with overlapping keys (second object wins)" {
    local json1='{"name": "John", "age": 30, "city": "Boston"}'
    local json2='{"age": 25, "city": "New York", "country": "USA"}'
    local expected='{"name":"John","age":25,"city":"New York","country":"USA"}'

    run json_merge_objects "${json1}" "${json2}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_merge_objects: should merge multiple objects" {
    local json1='{"a": 1}'
    local json2='{"b": 2}'
    local json3='{"c": "this has spaces\nand new line"}'
    local expected='{"a":1,"b":2,"c":"this has spaces\nand new line"}'

    run json_merge_objects "${json1}" "${json2}" "${json3}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_merge_objects: should handle empty objects" {
    local json1='{}'
    local json2='{"name": "John"}'
    local expected='{"name":"John"}'

    run json_merge_objects "${json1}" "${json2}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_merge_objects: should handle single object input" {
    local json1='{"name": "John", "age": 30}'
    local expected='{"name":"John","age":30}'

    run json_merge_objects "${json1}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_merge_objects: should fail with invalid JSON input" {
    local invalid_json='{"name": "John", "age":}'
    local valid_json='{"city": "New York"}'

    run json_merge_objects "${invalid_json}" "${valid_json}"
    [ "${status}" -eq 1 ]
}

@test "json_merge_objects: should fail with non-object JSON input (array)" {
    local json_array='["item1", "item2"]'
    local json_object='{"name": "John"}'

    run json_merge_objects "${json_array}" "${json_object}"
    [ "${status}" -eq 1 ]
}

@test "json_merge_objects: should fail with non-object JSON input (string)" {
    local json_string='"just a string"'
    local json_object='{"name": "John"}'

    run json_merge_objects "${json_string}" "${json_object}"
    [ "${status}" -eq 1 ]
}

@test "json_merge_objects: should fail with non-object JSON input (number)" {
    local json_number='42'
    local json_object='{"name": "John"}'

    run json_merge_objects "${json_number}" "${json_object}"
    [ "${status}" -eq 1 ]
}

@test "json_merge_objects: should handle nested objects" {
    local json1='{"user": {"name": "John", "age": 30}}'
    local json2='{"user": {"city": "New York"}, "active": true}'
    local expected='{"user":{"city":"New York"},"active":true}'

    run json_merge_objects "${json1}" "${json2}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_merge_objects: should handle complex nested structures" {
    local json1='{"config": {"debug": true, "timeout": 30}, "version": "1.0"}'
    local json2='{"config": {"port": 8080, "host": "localhost"}, "author": "test"}'
    local expected='{"config":{"port":8080,"host":"localhost"},"version":"1.0","author":"test"}'

    run json_merge_objects "${json1}" "${json2}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}

@test "json_merge_objects: should handle objects with different value types" {
    local json1='{"string": "text", "number": 42, "boolean": true}'
    local json2='{"array": [1, 2, 3], "null_value": null, "object": {"nested": "value"}}'
    local expected='{"string":"text","number":42,"boolean":true,"array":[1,2,3],"null_value":null,"object":{"nested":"value"}}'

    run json_merge_objects "${json1}" "${json2}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${expected}" ]
}
